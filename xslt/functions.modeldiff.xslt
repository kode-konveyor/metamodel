<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xmlns:html="http://www.w3.org/TR/xhtml1/transitional"
			xmlns:fn="http://www.w3.org/2005/xpath-functions"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:zenta="http://magwas.rulez.org/zenta"
            >

    <xsl:function name="zenta:path">
	    <xsl:param name="doc"/>
	    <xsl:param name="element"/>
	    <xsl:variable name="parent" select="$element/.."/>
	    <xsl:choose>
		    <xsl:when test="$parent/@id">
			    <xsl:variable name="path" select="zenta:path($doc,$parent)"/>	
			    <parent>
				    <xsl:attribute name="path" select="concat($path/@path,'|',$element/@name)"/>
				    <xsl:attribute name="idpath" select="concat($path/@idpath,'.',$element/@id)"/>
			    </parent>
		    </xsl:when>
		    <xsl:otherwise>
			    <parent>
				    <xsl:attribute name="path" select="$element/@name"/>
				    <xsl:attribute name="idpath" select="$element/@id"/>
			    </parent>
		    </xsl:otherwise>
	    </xsl:choose>
    </xsl:function>
    <xsl:function name="zenta:flatten">
	    <xsl:param name="doc"/>
        <xsl:for-each select="$doc//element|$doc//folder|$doc//zenta:model">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:attribute name="parent" select="../@id"/>
                <xsl:copy-of select="zenta:path($doc,.)"/>
                <xsl:copy-of select="*[local-name() != 'element' and local-name() != 'folder']"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:function>

</xsl:stylesheet>

