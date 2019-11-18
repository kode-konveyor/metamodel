<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xmlns:html="http://www.w3.org/TR/xhtml1/transitional"
			xmlns:fn="http://www.w3.org/2005/xpath-functions"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:zenta="http://magwas.rulez.org/zenta"
            >

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

    <xsl:include href="xslt/functions.modeldiff.xslt"/>
    <xsl:param name="newversion"/>
    <xsl:param name="oldversion"/>

    <xsl:variable name="newmodel" select="document($newversion)"/>

    <xsl:variable name="orig" select="zenta:flatten(/)"/>
    <xsl:variable name="new" select="zenta:flatten($newmodel)"/>

    <xsl:template match="/">
        <diff orig="{$oldversion}" now="{$newversion}">
        <xsl:for-each select="$new">
            <xsl:variable name="oldItem" select="$orig[@id=current()/@id]"/>
            <xsl:variable name="newItem" select="."/>
            <xsl:if test="not($oldItem/@id)">
                <new id="{$newItem/@id}">
                    <xsl:copy-of select="$newItem"/>
                </new>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$orig">
            <xsl:variable name="oldItem" select="."/>
            <xsl:variable name="newItem" select="$new[@id=current()/@id]"/>
            <xsl:if test="not($newItem/@id)">
                <deleted id="{$oldItem/@id}">
                    <xsl:copy-of select="$oldItem"/>
                </deleted>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$orig">
            <xsl:variable name="oldItem" select="."/>
            <xsl:variable name="newItem" select="$new[@id=current()/@id]"/>
            <xsl:if test="$oldItem/@id and $newItem/@id and not(deep-equal($oldItem,$newItem))">
                <changed id="{$oldItem/@id}">
                    <orig>
                        <xsl:copy-of select="$oldItem"/>
                    </orig>
                    <now>
                        <xsl:copy-of select="$newItem"/>
                    </now>
                </changed>
            </xsl:if>
        </xsl:for-each>
        </diff>
    </xsl:template>

</xsl:stylesheet>

