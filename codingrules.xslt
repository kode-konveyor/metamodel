<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xml>
<xsl:stylesheet
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			version='2.0'
			xmlns:xhtml="http://www.w3.org/TR/xhtml1/transitional"
			xmlns:fn="http://www.w3.org/2005/xpath-functions"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:zenta="http://magwas.rulez.org/zenta">

	<xsl:import href="xslt/functions.xslt"/>

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

	<xsl:variable name="doc" select="/"/>
	<xsl:template match="/">
	<article>
		<section id="cleancode">
			<title>Clean Code Rules</title>
			<variablelist>
				<xsl:for-each select="zenta:neighbours(/,//element[@name='Clean Code' and @xsi:type='Objective'],'determines,1')">
					<varlistentry>
						<term><xsl:value-of select="@name"/></term>
						<listitem>
						<para>
							<xsl:copy-of select="documentation/(text()|*)"/>
						</para>
						</listitem>
					</varlistentry>
				</xsl:for-each>
			</variablelist>
		</section>
		<section id="codingrules">
			<title>Coding Rules</title>
			<xsl:for-each select="zenta:neighbours(/,//element[@name='Code' and @xsi:type='Business Object'],'aggregates,1')">
				<section>
					<xsl:copy-of select="@id"/>
					<title><xsl:value-of select="@name"/></title>
					<para>
						<xsl:copy-of select="documentation/(text()|*)"/>
					</para>
					<para>
					Rules:
						<variablelist>
							<xsl:for-each select="zenta:neighbours($doc,.,'concerns,2')">
								<varlistentry>
									<term><xsl:value-of select="@name"/></term>
									<listitem>
									<para>
										<xsl:copy-of select="documentation/(text()|*)"/>
									</para>
									</listitem>
								</varlistentry>
							</xsl:for-each>
						</variablelist>
					</para>
				</section>
			</xsl:for-each>
		</section>
	</article>
	</xsl:template>
</xsl:stylesheet>

