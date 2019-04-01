all: install

install: compile 
	cp -rf metamodel/* target

target:
	mkdir -p target

compile: zentaworkaround metamodel.compiled 

include /usr/share/zenta-tools/model.rules

testenv:
	./tools/testenv

clean:
	git clean -fdx
	rm -rf zenta-tools

inputs/metamodel.issues.xml: target/metamodel-implementedBehaviours.xml target/metamodel-testcases.xml
	mkdir -p inputs
	tools/getGithubIssues kode-konveyor metamodel >inputs/metamodel.issues.xml

zentaworkaround:
	mkdir -p ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	cp workbench.xmi ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	touch zentaworkaround

