<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xmlns:html="http://www.w3.org/TR/xhtml1/transitional"
			xmlns:fn="http://www.w3.org/2005/xpath-functions"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:zenta="http://magwas.rulez.org/zenta"
            >

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="no" omit-xml-declaration="yes"/>

    <xsl:param name="diffdir"/>
    <xsl:param name="apply"/>
    <xsl:variable name="old" select="document(/diff/@orig)"/>
    <xsl:variable name="new" select="document(/diff/@now)"/>


  <xsl:template match="@*|*|processing-instruction()|comment()" mode="merge">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="merge"/>
    </xsl:copy>
  </xsl:template>

    <xsl:template match="*[@id]" mode="merge">
        <xsl:param name="change" tunnel="yes"/>
        <xsl:variable name="deletedId" select="$change/@id|$change/old/@id"/>
        <xsl:variable name="newId" select="$change[local-name()='new']/*/@parent|$change/now/*/@parent"/>
        <xsl:copy>
            <xsl:apply-templates select="*[@id!=$deletedId]|*|@*|text()|processing-instruction()|comment()" mode="merge"/>
            <xsl:if test="@id=$newId">
                <xsl:copy-of select="if (local-name($change) = 'new')
                    then
                        $change/*
                    else
                        $change/now/*"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="zenta:applyChanges">
        <xsl:param name="doc"/>
        <xsl:param name="changes"/>
        <xsl:choose>
            <xsl:when test="$changes/@id">
                <xsl:variable name="change" select="$changes[1]"/>
                <xsl:variable name="otherChanges" select="$changes[position() >1]"/>
                <xsl:variable name="newDoc">
                    <xsl:apply-templates select="$doc" mode="merge">
                        <xsl:with-param name="change" tunnel="yes" select="$change"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:copy-of select="zenta:applyChanges($newDoc, $otherChanges)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$doc"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="/">
        <xsl:variable name="changes" select="/diff/*[@id = tokenize($apply,' ')]"/>
        <xsl:copy-of select="zenta:applyChanges($old,$changes)"/>
    </xsl:template>

</xsl:stylesheet>
