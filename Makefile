all: install

install: target zentaworkaround compile 
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

inputs/metamodel.issues.xml: 
	mkdir -p inputs
	touch inputs/metamodel.issues.xml

zentaworkaround:
	mkdir -p ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	cp /usr/local/toolchain/etc/workbench.xmi ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	touch zentaworkaround

