<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xmlns:html="http://www.w3.org/TR/xhtml1/transitional"
			xmlns:fn="http://www.w3.org/2005/xpath-functions"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:zenta="http://magwas.rulez.org/zenta"
            >

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="no" omit-xml-declaration="yes"/>

    <xsl:param name="metamodel"/>
    <xsl:param name="add" select="''"/>
    <xsl:variable name="metamodeldoc" select="document($metamodel)"/>

  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="folder[@id=$metamodeldoc//folder[@id='metamodel']/folder/@id]">
  <xsl:message select="concat('updating ',@name)"/>
  	<xsl:copy>
  		<xsl:copy-of select="@id|@name|property"/>
  		<xsl:copy-of select="$metamodeldoc//folder[@id=current()/@id]/*"/>
  	</xsl:copy>
  </xsl:template>
  
  <xsl:template match="folder[@id='metamodel']">
    <xsl:message select="concat(
    	'parts in metamodel:&#10; ',
    	string-join(
    		for $part in $metamodeldoc//folder[@id='metamodel']/folder
    			return
    				concat($part/@name,':',$part/@id,'&#10;'),
    		' '
    	)
     )"/>
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
      <xsl:for-each select="tokenize($add,',')">
      	<xsl:variable name="toAdd" select="$metamodeldoc//folder[@id=current()]"/>
      	<xsl:message select="concat('adding ',$toAdd/@name)"/>
      	<xsl:copy-of select="$toAdd"/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
