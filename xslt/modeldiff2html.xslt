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
    <xsl:param name="diffdir"/>
    <xsl:variable name="old" select="document(/diff/@orig)"/>
    <xsl:variable name="new" select="document(/diff/@now)"/>


  <xsl:template match="@*|*|processing-instruction()|comment()" mode="noParent">
    <xsl:copy>
      <xsl:apply-templates select="*|@*[local-name() != 'parent']|text()|processing-instruction()|comment()" mode="noParent"/>
    </xsl:copy>
  </xsl:template>

    <xsl:template match="/">
        <html><head>
        <title>diff between <xsl:value-of select="concat(/diff/@orig,' and ', /diff/@now)"/></title>
        <script>
function toggleAll(ids) {
    for(i in ids) {
        id = ids[i]
        checkbox = document.getElementById("checkbox-"+id)
        state=checkbox.checked
        checkbox.checked=not(state)
        if(state) {
            display="inline";
        } else {
            display="none";
        }
        document.getElementById("span-"+id).style.display=display;
    }
}
function toggle(id) {
  state=document.getElementById("checkbox-"+id).checked;
  if(state) {
    display="inline";
  } else {
    display="none";
  }
  document.getElementById("span-"+id).style.display=display;
}
</script>
        </head><body width="100%">
            <h1>diff between <xsl:value-of select="concat(/diff/@orig,' and ', /diff/@now)"/></h1>
            <h2>diagrams</h2>
            <xsl:for-each select="/diff/*[.//@xsi:type='zenta:ZentaDiagramModel']">
                <xsl:choose>
                    <xsl:when test="local-name() = 'new'">
                        <h3>new: <xsl:value-of select="element/parent/@path"/></h3>
                        <input onclick="javascript:clicked('{*/@id}')" type="checkbox" id="checkbox-{*/@id}">Use it</input><p/>
                        <input onclick="javascript:clicked('{*/@id}')" type="checkbox" id="checkbox-{*/@id}">Use it for all relevant elements</input><p/>
                        <img src="new/pics/{element/@id}.png" width="50%"/>
                        <xsl:value-of select=".//(@zentaElement|@relationship)"/>
                    </xsl:when>
                    <xsl:when test="local-name() = 'deleted'">
                        <h3>deleted: <xsl:value-of select="element/parent/@path"/></h3>
                        <input onclick="javascript:clicked('{*/@id}')" type="checkbox" id="checkbox-{*/@id}">Use it</input><p/>
                        <input onclick="javascript:clicked('{*/@id}')" type="checkbox" id="checkbox-{*/@id}">Use it for all relevant elements</input><p/>
                        <img src="old/pics/{element/@id}.png" width="50%"/>
                    </xsl:when>
                    <xsl:when test="local-name() = 'changed'">
                        <h3>changed: <xsl:value-of select="element/parent/@path"/></h3>
                        <input onclick="javascript:clicked('{*/@id}')" type="checkbox" id="checkbox-{*/@id}">Use it</input><p/>
                        <input onclick="javascript:clicked('{*/@id}')" type="checkbox" id="checkbox-{*/@id}">Use it for all relevant elements</input><p/>
                        <table>
                        <tr>
                        <td>orig: <xsl:value-of select="orig/element/parent/@path"/></td>
                        <td>now: <xsl:value-of select="now/element/parent/@path"/></td>
                        </tr>
                        <tr>
                        <td><img src="old/pics/{orig/element/@id}.png" width="50%"/></td>
                        <td><img src="new/pics/{now/element/@id}.png" width="50%"/></td>
                        </tr>
                        </table>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
<!--
            <h2>New elements</h2>
            <xsl:for-each select="/diff/new">
            <h3>new: <xsl:copy-of select="zenta:pathToId($new,*/@id)"/></h3>
                <input onclick="javascript:clicked('{*/@id}')" type="checkbox" id="checkbox-{*/@id}">Use it</input><p/>
                <xsl:choose>
                    <xsl:when test="*/@xsi:type = 'zenta:ZentaDiagramModel'">
                        <img src="new/pics/{*/@id}.png" width="50%"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <textarea rows="10" cols="180">
                            <xsl:copy-of select="*"/>
                        </textarea>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <h2>Deleted elements</h2>
            <xsl:for-each select="/diff/deleted">
            <h3>deleted: <xsl:copy-of select="zenta:pathToId($old,*/@id)"/></h3>
                <input onclick="javascript:clicked('{*/@id}')" type="checkbox" id="checkbox-{*/@id}">Use it</input><p/>
                <xsl:choose>
                    <xsl:when test="*/@xsi:type = 'zenta:ZentaDiagramModel'">
                        <img src="old/pics/{*/@id}.png" width="50%%"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <textarea rows="10" cols="180">
                            <xsl:copy-of select="*"/>
                        </textarea>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <h2>Changed elements</h2>
            <xsl:for-each select="/diff/changed">
                <xsl:choose>
                    <xsl:when test="orig/*/@parent = now/*/@parent">
                        <h3>changed: <xsl:copy-of select="zenta:pathToId($new,now/*/@id)"/></h3>
                    </xsl:when>
                    <xsl:otherwise>
                        <h3>moved: <xsl:copy-of select="concat(zenta:pathToId($old,now/*/@id),' to ',zenta:pathToId($new,now/*/@id))"/></h3>
                    </xsl:otherwise>
                </xsl:choose>
                <input onclick="javascript:clicked('{orig/*/@id}')" type="checkbox" id="checkbox-{orig/*/@id}">Use it</input><p/>
                <xsl:variable name="withoutParent">
                    <xsl:apply-templates select="." mode="noParent"/>
                </xsl:variable>
                <f>
                <xsl:copy-of select="orig/*/@xsi:type"/>
                </f>
                <xsl:choose>
                    <xsl:when test="orig/*/@xsi:type = 'zenta:ZentaDiagramModel'">
                        <table width="100%" border="1"><row><td>
                        <img src="old/pics/{orig/*/@id}.png" width="100%"/>
                        </td><td>
                        <img src="new/pics/{orig/*/@id}.png" width="100%"/>
                        </td></row></table>
                    </xsl:when>
                    <xsl:otherwise>
                        <textarea rows="20" cols="180">
                        <xsl:copy-of select="$withoutParent"/>
                        </textarea>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
-->
            <p/>Used ids: 
            <xsl:for-each select="//(new|deleted|changed)/@id">
                <span style="display:none" id="span-{.}"><xsl:value-of select="."/></span>
            </xsl:for-each>
        </body></html>
    </xsl:template>

</xsl:stylesheet>
