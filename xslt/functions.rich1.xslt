<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:zenta="http://magwas.rulez.org/zenta"
	xmlns:zentatools="java:org.rulez.magwas.zentatools.XPathFunctions"
    xmlns:saxon="http://saxon.sf.net/"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

        <xsl:function name="zenta:neighbourPlain">
                <xsl:param name="context"/>
                <xsl:param name="current"/>
                <xsl:param name="relationname"/>
                <xsl:param name="direction"/>
                <xsl:for-each select="$context">
                        <xsl:copy-of select="$context//element[@id = $context//connection[@source=$current/@id and @ancestorName=$relationname and @direction=$direction]/@target]"/>
                </xsl:for-each>
        </xsl:function>

    <xsl:function name="zenta:neighboursRun1">
        <xsl:param name="context"/>
        <xsl:param name="current"/>
        <xsl:param name="pathstring"/>
        <xsl:variable name="path" select="tokenize($pathstring,';')"/>
        <xsl:variable name="next" select="$path[1]"/>
        <xsl:variable name="rest" select="string-join(subsequence($path,2,count($path)),';')"/>
        <xsl:variable name="nextsequence" select="tokenize($next,',')"/>
        <xsl:variable name="neighbours" select="
                        zenta:neighbourPlain($context,$current,$nextsequence[1],$nextsequence[2])
        "/>
        <xsl:choose>
                <xsl:when test="$rest">
                        <xsl:for-each select="$neighbours">
                                <xsl:copy-of select="
                                        zenta:neighboursRun1(
                                                $context,
                                                .,
                                                $rest)"/>
                        </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                        <xsl:copy-of select="$neighbours"/>
                </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


	<xsl:function name="zenta:descendantRelations">
		<xsl:param name="relation"/>
		<xsl:param name="doc"/>
		<xsl:copy-of select="$relation"/>
		<xsl:variable name="descendants" select="$doc//connection[
			@ancestor=$relation/@id and
			@template='true' and
			@direction=$relation/@direction
			]"/>
		<xsl:for-each select="$descendants">
			<xsl:copy-of select="zenta:descendantRelations(.,$doc)"/>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="zenta:descendantRelationsFor">
		<xsl:param name="relation"/>
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
		<xsl:variable name="descendants" select="$doc//connection[
			@ancestor=$relation/@id and
			@template='true' and
			@direction=$relation/@direction
			]"/>
		<xsl:copy-of select="$doc//connection[
			@ancestor=$relation/@id and
			@template='false' and
			@direction=$relation/@direction and
			@source=$element/@id
			]"/>
		<xsl:for-each select="$descendants">
			<xsl:copy-of select="zenta:descendantRelationsFor(.,$element,$doc)"/>
		</xsl:for-each>
	</xsl:function>
	


	<xsl:function name="zenta:getMinOccurs">
		<xsl:param name="doc"/>
		<xsl:param name="element"/>
		<xsl:choose>
			<xsl:when test="$element/property[@key='minOccurs']">
				<xsl:copy-of select="$element/property[@key='minOccurs']/@value"/>
			</xsl:when>
			<xsl:when test="$doc//element[@id=$element/@ancestor]">
				<xsl:copy-of select="zenta:getMinOccurs($doc,$doc//element[@id=$element/@ancestor])"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="'-1/-1'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="zenta:getMaxOccurs">
		<xsl:param name="doc"/>
		<xsl:param name="element"/>
		<xsl:choose>
			<xsl:when test="$element/property[@key='maxOccurs']">
				<xsl:copy-of select="$element/property[@key='maxOccurs']/@value"/>
			</xsl:when>
			<xsl:when test="$doc//element[@id=$element/@ancestor]">
				<xsl:copy-of select="zenta:getMaxOccurs($doc,$doc//element[@id=$element/@ancestor])"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="'-1/-1'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="zenta:buildConnection">
		<xsl:param name="element"/>
		<xsl:param name="direction"/>
		<xsl:param name="doc"/>
			<xsl:variable name="mO" select="zenta:getMinOccurs($doc,$element)"/>
			<xsl:variable name="xO" select="zenta:getMaxOccurs($doc,$element)"/>
			<connection>
				<xsl:choose>
					<xsl:when test="$direction=1">
						<xsl:attribute name="source" select="$element/@source"/>
						<xsl:attribute name="target" select="$element/@target"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="source" select="$element/@target"/>
						<xsl:attribute name="target" select="$element/@source"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:attribute name="direction" select="$direction"/>
				<xsl:attribute name="minOccurs" select="zenta:occursNumber(tokenize($mO,'/')[$direction])"/>
				<xsl:attribute name="maxOccurs" select="zenta:occursNumber(tokenize($xO,'/')[$direction])"/>
				<xsl:attribute name="template" select="$doc//element[property/@key='Template']//sourceConnection/@relationship=$element/@id"/>
				<xsl:attribute name="relationName" select="$element/@name"/>
				<xsl:attribute name="ancestorName" select="$doc//element[@id=$element/@ancestor]/@name"/>
				<xsl:copy-of select="$element/@ancestor|$element/@id|$element/@name|$element/documentation"/>
			</connection>
	</xsl:function>

	<xsl:function name="zenta:getRelationDescentry">
		<xsl:param name="element"/>
		<xsl:param name="direction"/>
		<xsl:param name="doc"/>
		<xsl:if test="$element">
			<xsl:copy-of select="zenta:getRelationDescentry($doc//connection[@ancestor=$element/@id and @direction=$direction and @template='true'],$direction,$doc)"/>
			<xsl:copy-of select="$element"/>
		</xsl:if>
	</xsl:function>

	<xsl:function name="zenta:getAncestry">
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
		<xsl:if test="$element">
			<xsl:copy-of select="zenta:getAncestry($doc//element[@id=$element/@ancestor],$doc)"/>
			<xsl:copy-of select="$element"/>
		</xsl:if>
	</xsl:function>

	<xsl:function name="zenta:getDefiningRelations">
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
		<xsl:for-each select="zenta:getAncestry($element,$doc)">
			<xsl:copy-of select="$doc//connection[@source=current()/@ancestor]"/>
		</xsl:for-each>
	</xsl:function>



    <xsl:function name="zenta:addDerivedRelations">
        <xsl:param name="doc"/>
        <xsl:param name="element"/>
        <xsl:param name="definingRelations"/>
        <xsl:variable name="ancestry" select="zenta:getAncestry($element,$doc)[position() &lt; last()]"/>
        <xsl:for-each select="zenta:findDerivedRelations($doc,$element, $ancestry)">
            <xsl:variable name="target" select="."/>
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="direction" select="@direction"/>
            <xsl:for-each select="saxon:evaluate(@xpath,$doc,$element)">
	        <xsl:variable name="templateRelation">
	            <xsl:copy-of select="$doc//connection[@source=$ancestry/@id and @relationName=$name and @direction=$direction and @target=zenta:getAncestry(current(),$doc)/@id]"/>
	        </xsl:variable>
		<xsl:if test="count($templateRelation/connection) != 1">
			    <xsl:message select="'---self'"/>
			    <xsl:message select="."/>
			    <xsl:message select="'---element'"/>
			    <xsl:message select="$element"/>
			    <xsl:message select="'---element ancestry'"/>
			    <xsl:message select="$ancestry/concat(@name,':',@id,'&#10;')"/>
			    <xsl:message select="'---self ancestry'"/>
			    <xsl:message select="zenta:getAncestry(.,$doc)/concat(@name,':',@id,codepoints-to-string(10))"/>
			    <xsl:message select="'---connections'"/>
			    <xsl:message select="$doc//connection[@source=$ancestry/@id and @relationName=$name and @direction=$direction]"/>
	            <xsl:message terminate="yes">
	             Invalid derived relation, no template found to: <xsl:copy-of select="."/>
		     Not one connection with name '<xsl:value-of select="$name"/>' and direction '<xsl:value-of select="$direction"/>'
		     from <xsl:copy-of select="$element"/>,
		     with ancestry <xsl:for-each select="$ancestry">
			<xsl:copy-of select="@name"/>,
		     </xsl:for-each>
		     defined by <xsl:copy-of select="$target"/>
		     relations: <xsl:copy-of select="$templateRelation/connection"/>
	            </xsl:message>
	        </xsl:if>
                <value derived="true">
                    <xsl:copy-of select="@name|$templateRelation/connection/@direction"/>
                    <xsl:attribute name="ancestorName" select="$name"/>
                    <xsl:attribute name="source" select="$element/@id"/>
                    <xsl:attribute name="target" select="@id"/>
                    <xsl:attribute name="ancestor" select="$templateRelation/connection/@id"/>
		    <xsl:attribute name="id" select="concat($element/@id,'-',$templateRelation/connection/@id,'-',@id)"/>
                </value>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="zenta:findDerivedRelations">
        <xsl:param name="doc"/>
        <xsl:param name="element"/>
        <xsl:param name="ancestry"/>
        <xsl:for-each select="$ancestry">
            <xsl:for-each select="zenta:neighboursRun1($doc,.,'expands,2')">
                <derived>
                    <xsl:copy-of select="@name|@id"/>
                    <xsl:attribute name="direction" select="tokenize(documentation,'\|')[1]"/>
                    <xsl:attribute name="xpath" select="string-join(tokenize(documentation,'\|')[position() > 1], '|')"/>
                </derived>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>

</xsl:stylesheet>
