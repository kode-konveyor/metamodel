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
		<xsl:copy>
			<xsl:copy-of select="@*|./property"/>
		</xsl:copy>
		<xsl:result-document href="{$outputfile}">
			<xsl:copy>
				<xsl:apply-templates select="./(@*|*)" mode="delink"/>
			</xsl:copy>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="folder[property/@key='source']" mode="link">
		<xsl:variable name="outputfile" select="zenta:makeUrlFromSource(property[@key='source']/@value)"/>
		<xsl:apply-templates select="document($outputfile)" mode="linkfirst"/>
		<xsl:message select="concat(property[@key='source']/@value,':',$outputfile)"/>
	</xsl:template>

	<xsl:template match="folder" mode="linkfirst">
		<xsl:copy>
			<xsl:apply-templates select="./(@*|*)" mode="link"/>
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
