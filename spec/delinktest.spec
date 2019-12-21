<?xml version="1.0" encoding="UTF-8"?>
<testcases testdata="testdata.xml" sut="xslt/delink.xslt">
	<functionstub function="zenta:save" numArgs="2" when="$p1/arg1='target/frontend/test.zenta'" return="()"/>
	<templatestub mode="foo" match="foo" result="$p1/foo"/>
	<test
		description="folder with source designation is saved under target as the designated name"
		data="$p1//folder[@name='test']"
		run="apply"
		test="$p2//called[
			@function='zenta:save' and
			arg1='target/frontend/test.zenta' and
			arg2/property/key='save']"
	/>
	<test
		description="simple apply test"
		data="$p1//test1/*"
		run="apply"
		test="not(not($p1/foo))"
	/>
	<test
		description="model source url is calculated for folder source correctly"
		data="'frontend/requirements.zenta'"
		run="zenta:makeUrlFromSource($p1)"
		test="$p1='model/requirements.zenta'"
	/>
</testcases>
