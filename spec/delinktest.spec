<?xml version="1.0" encoding="UTF-8"?>
<testcases testdata="testdata.xml" sut="xslt/delink.xslt">
	<functionstub function="zenta:save" numArgs="2" when="$doc/arg1='target/frontend/test.zenta'" return="()"/>
	<templatestub mode="foo" match="foo" result="$doc/foo"/>
	<test
		description="folder with source designation is saved under target as the designated name"
		data="$doc//folder[@name='test']"
		run="apply"
		test="$element//called[
			@function='zenta:save' and
			arg1='target/frontend/test.zenta' and
			arg2/property/key='save']"
	/>
	<test
		description="simple apply test"
		data="$doc//test1/*"
		run="apply"
		test="not(not($doc/foo))"
	/>
	<test
		description="model source url is calculated for folder source correctly"
		data="'frontend/requirements.zenta'"
		run="zenta:makeUrlFromSource($doc)"
		test="$doc='model/requirements.zenta'"
	/>
</testcases>
