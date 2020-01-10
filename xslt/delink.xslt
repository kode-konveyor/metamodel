<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xml>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version='2.0'
	xmlns:xhtml="http://www.w3.org/TR/xhtml1/transitional"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:zenta="http://magwas.rulez.org/zenta">


	<xsl:param name="targetdir"/>

	<xsl:variable name="zentasources" select="document(concat($targetdir,'/.zentasources'))"/>
	<xsl:function name="zenta:makeUrlFromSource">
		<xsl:param name="locator"/>
		<xsl:variable name="folder" select="tokenize($locator,'/')[1]"/>
		<xsl:variable name="path" select="string-join(tokenize($locator,'/')[position()>1],'/')"/>
		<xsl:variable name="source" select="$zentasources//source[@name=$folder]"/>
		<xsl:variable name="type" select="$source/@type"/>
		<xsl:choose>
			<xsl:when test="$type = 'uri'">
				<xsl:value-of select="concat($source/@uri,'/',$path,'.zentapart')"/>
			</xsl:when>
			<xsl:when test="$type = 'folder'">
				<xsl:value-of select="concat('file://',$targetdir,'/', $source/@uri,'/',$path,'.zentapart')"/>
			</xsl:when>
			<xsl:when test="$type = 'github'">
				<xsl:value-of select="concat('file://',$targetdir,'/', 'inputs/',$source/@repo,'/',$source/@path,'/',$path,'.zentapart')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes" select="concat('unknown type for ',$locator, ' type:', $type)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template match="*|@*|text()" mode="delink link prepare">
		<xsl:copy>
			<xsl:apply-templates select="*|@*|text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="folder[property/@key='source']" mode="delink">
		<xsl:variable name="outputfile" select="concat($targetdir,'/modelparts/',property[@key='source']/@value,'.zentapart')"/>
		<xsl:message select="$outputfile"/>
		<xsl:result-document href="{$outputfile}">
			<xsl:copy>
				<xsl:apply-templates select="./(@*|*)" mode="delink"/>
			</xsl:copy>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="property[@key='source']" mode="delink"/>

	<xsl:template match="*[property/@key='modelDependency']" mode="link">
		<xsl:variable name="dependencies">
			<xsl:for-each select="property[@key='modelDependency']/@value">
				<xsl:variable name="outputfile" select="zenta:makeUrlFromSource(.)"/>
				<xsl:apply-templates select="document($outputfile)" mode="linkfirst">
					<xsl:with-param name="source" select="."/>
				</xsl:apply-templates>
				<xsl:message select="concat(.,':',$outputfile)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="providedIds" select="tokenize(string-join($dependencies//@id|.//@id,' '),' ')"/>
		<xsl:variable name="requiredIds" select="tokenize(string-join(.//(@source|@target|@relationship|@zentaElement|@ancestor),' '),' ')"/>
		<xsl:variable name="notProvided" select="for $required in $requiredIds return if($required = $providedIds) then () else $required"/>
		<xsl:message select="count($providedIds)"/>
		<xsl:message select="count($requiredIds)"/>
		<xsl:message select="count($notProvided)"/>
		<xsl:if test="count($notProvided) != 0">
			<xsl:message terminate="no">
				<xsl:text>No dependency is provided for the following ids: </xsl:text>
				<xsl:value-of select="$notProvided"/>
			</xsl:message>
		</xsl:if>
		<xsl:copy>
			<xsl:apply-templates select="*|@*|text()" mode="link"/>
			<xsl:apply-templates select="$dependencies" mode="link"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="folder" mode="linkfirst">
		<xsl:param name="source"/>
		<xsl:copy>
			<xsl:apply-templates select="./(@*|*)" mode="link"/>
			<property key="source" value="{$source}"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/" mode="prepare">
		<xsl:apply-templates select="$zentasources//source" mode="prepare"/>
	</xsl:template>

	<xsl:template match="source" mode="prepare"/>

	<xsl:template match="source[@type='github']" mode="prepare">
		<xsl:variable name="targetdir" select="concat('inputs/',@repo)"/>
		<xsl:value-of select="concat('rm -rf ',$targetdir,';git clone --branch ',@branch,' git@github.com:',@repo,'.git ',$targetdir,'&#10;')"/>
	</xsl:template>
</xsl:stylesheet>
