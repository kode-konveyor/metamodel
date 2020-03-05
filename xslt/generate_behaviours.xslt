<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xml>
<xsl:stylesheet version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:zenta="http://magwas.rulez.org/zenta"
	xmlns:zentatools="java:org.rulez.magwas.zentatools.XPathFunctions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8"
		indent="yes" omit-xml-declaration="yes" />

	<xsl:include href="xslt/functions.xslt" />

	<xsl:param name="modelbasename" />
	<xsl:param name="reponame" />
	<xsl:param name="github_org" />

    <xsl:variable name="zenta" select="document(concat($modelbasename,'.zenta'))"/>
    <xsl:variable name="implemented" select="document('shippable/implementedBehaviours.xml')"/>
    <xsl:variable name="issues" select="document('inputs/issues.xml')"/>
    <xsl:variable name="rich" select="/"/>

    <xsl:function name="zenta:camelCase">
	    <xsl:param name="text"/>
	    <xsl:value-of select="string-join(for $word in tokenize($text,' ') return concat(upper-case(substring($word,1,1)),
          substring($word, 2),
          ' '[not(last())]
	  ),'') "/>
    </xsl:function>
	<xsl:template match="/">
		<xsl:variable name="behaviours">
			<tasks>
				<xsl:call-template name="behaviours" />
			</tasks>
		</xsl:variable>
		<xsl:result-document
			href="shippable/behaviours.txt">
			<xsl:copy-of
				select="zenta:writeTestcasesAsText($behaviours)" />
		</xsl:result-document>
		<xsl:result-document
			href="shippable/behaviours.xml">
			<xsl:copy-of select="$behaviours" />
		</xsl:result-document>
        <xsl:copy-of select="
        codepoints-to-string(10),
        $behaviours//task/concat(
            @status,
            substring(':                  ',1,20 - string-length(@status)),
            @service,'/',
            @behaviour,' ',
            @issueUrl,
            codepoints-to-string(10)),
        codepoints-to-string(10)
        "/>
	</xsl:template>


    <xsl:function name="zenta:drawpic">
        <xsl:param name="picid"/>
            <xsl:variable name="picname" select="$zenta//element[@id=$picid]/@name"/>
            <xsl:variable name="piclink" select="concat(
                'https://repository.kodekonveyor.com/',
               $reponame,
               '/',
               $github_org,
               '/develop/pics/',
               $picid,
               '.png')"/>
            <xsl:variable name="doclink" select="concat(
                'https://repository.kodekonveyor.com/',
               $reponame,
               '/',
               $github_org,
               '/develop/index.html#',
               $picid)"/>
<xsl:text>
</xsl:text>
<xsl:value-of select="$picname"/>
[![<xsl:value-of select="$picname"/>](<xsl:value-of select="$piclink"/>)](<xsl:value-of select="$doclink"/>)
    </xsl:function>

	<xsl:function name="zenta:writeTestcasesAsText">
		<xsl:param name="behaviours" />
		<xsl:for-each select="$behaviours//task">
----------------------------------------------------------------------------
Behaviour: <xsl:value-of select="concat(@service, '/', @behaviour)" />

Annotations for the test cases:

    @TestedBehaviour("<xsl:value-of select="@behaviour" />")
    @TestedService("<xsl:value-of select="@service" />")

The production code is at <xsl:value-of select="concat(@package, '.', @service)" />.java
The testcase base should be at <xsl:value-of select="concat(@package, '.', @service)" />TestBase.java
The testcase should probably be at <xsl:value-of select="concat(@package, '.', @service)" /><xsl:value-of select="zenta:camelCase(@behaviour)"/>Test.java

<xsl:copy-of select="$zenta//element[@id=current()/behaviour/element/@id]/documentation/(*|text())"/>

  <xsl:variable name="serviceview" select="$zenta//element[@id=current()/service/element/@id]/../*[.//child[@zentaElement=current()/service/element/@id]]"/>
  <xsl:variable name="dataobjects" select="$rich//element[@id=$serviceview//@zentaElement and (@xsi:type='DTO' or @xsi:type='Entity')]"/>
The service:
	<xsl:for-each select="$serviceview/@id">
                <xsl:copy-of select="zenta:drawpic(.)"/>
        </xsl:for-each>
DTOs and Entities:
	<xsl:for-each select="$dataobjects">
        <xsl:variable name="view" select="../*[.//@zentaElement=current()/@id]"/>
                <xsl:copy-of select="zenta:drawpic($view/@id)"/>
        </xsl:for-each>

If you have questions, see the [FAQ](https://kodekonveyor.com/coder-faq/), or ask on the [development slack channel](https://app.slack.com/client/TDHQX8Q66/CH9KFMCMU/thread/GKCB5T7CJ-1567418169.000200) or ask your mentor.

		</xsl:for-each>
	</xsl:function>

    <xsl:function name="zenta:fullpackageP">
        <xsl:param name="package"/>
        <xsl:if test="$package">
            <xsl:variable name="parent" select="zenta:fullpackageP(zenta:neighbours($rich,$package,'contains,2')[@xsi:type='Package'])"/>
            <xsl:choose>
                <xsl:when test="$parent">
<xsl:message select="$parent/@name"/>
<xsl:message select="$package/@name"/>
                    <xsl:value-of select="concat($parent, '.', $package/@name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$package/@name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>

    <xsl:function name="zenta:fullpackage">
        <xsl:param name="service"/>
        <xsl:variable name="parent" select="zenta:neighbours($rich,$service,'contains,2')[@xsi:type='Package' or @xsi:type='Process Step']"/>
        <xsl:choose>
            <xsl:when test="$parent/@xsi:type='Package'">
                <xsl:copy-of select="zenta:fullpackageP($parent)"/>
            </xsl:when>
            <xsl:when test="$parent/@xsi:type='Process Step'">
                <xsl:copy-of select="zenta:fullpackageP($parent)"/>
            </xsl:when>
            <xsl:otherwise>
        	<xsl:variable name="implementor" select="zenta:neighbours($rich,$service,'is implemented by/implements,2')"/>
	        <xsl:if test="not($implementor/@name)">
			<xsl:message select="$service"/>
			<xsl:message terminate="yes" select="concat('no package for ',$service/@name)"/>
	        </xsl:if>
                <xsl:copy-of select="zenta:fullpackage($implementor)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

	<xsl:template name="behaviours">
		<xsl:variable name="root" select="/" />
		<xsl:for-each
			select="//element[@template='false' and (@xsi:type='Behaviour')]">
            <xsl:variable name="behaviour" select="."/>
            <xsl:for-each select="zenta:neighbours(/,.,'is implemented by/implements,1')">
                <task>
                    <xsl:attribute name="service" select="@name"/>
                    <xsl:attribute name="behaviour" select="$behaviour/@name"/>
                    <xsl:attribute name="package" select="zenta:fullpackage(.)"/>
                    <xsl:variable name="implementedBehaviour" select="$implemented//behaviour[@name = $behaviour/@name and ../@service=current()/@name]"/>
                    <xsl:variable name="issue" select="$issues//issue[summary=concat(current()/@name,'/',$behaviour/@name)]"/>
                    <xsl:attribute name="issueUrl" select="$issue/@url"/>
                    <xsl:attribute name="status" select="
                        if($issue/@status = 'open')
                        then
                            if(not($implementedBehaviour/testcase))
                            then
                                'open'
                            else
                                'should-be-closed'
                        else
                            if(not($implementedBehaviour/testcase))
                            then
                                'should-make-issue'
                            else
                                'ready'
                    "/>
                    <implemented>
                        <xsl:copy-of select="$implementedBehaviour/testcase"/>
                    </implemented>
                    <xsl:copy-of select="$issue"/>
                    <service><xsl:copy-of select="."/></service>
                    <behaviour><xsl:copy-of select="$behaviour"/></behaviour>
                </task>
            </xsl:for-each>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>

