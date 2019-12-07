export MODEL_BASENAME=metamodel
export REPO_NAME=metamodel
export GITHUB_ORGANIZATION=kode-konveyor
export LANGUAGE=java
export JAVA_TARGET=none
export CONSISTENCY_INPUTS=metamodel.rich inputs/issues.xml
export AFTER_COMPILE=shippable/codingrules.html

include /usr/local/toolchain/rules.zenta

shippable/codingrules.docbook: metamodel.richescape
	zenta-xslt-runner -xsl:codingrules.xslt -s:metamodel.richescape -o:shippable/codingrules.docbook
