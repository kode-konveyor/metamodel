export MODEL_BASENAME=metamodel
export REPO_NAME=metamodel
export GITHUB_ORGANIZATION=kode-konveyor
export SONAR_ORG=$(GITHUB_ORGANIZATION)
export LANGUAGE=java

install: zentaworkaround metamodel.compiled shippable

inputs/metamodel.issues.xml:
	mkdir -p inputs
	touch inputs/metamodel.issues.xml

include /usr/share/zenta-tools/model.rules

clean:
	git clean -fdx

inputs/metamodel.issues.xml: 
	mkdir -p inputs
	touch inputs/metamodel.issues.xml

zentaworkaround:
	mkdir -p ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	cp /usr/local/toolchain/etc/workbench.xmi ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	touch zentaworkaround

shippable: metamodel.compiled
	mkdir -p shippable
	cp metamodel shippable
