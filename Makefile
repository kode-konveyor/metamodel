export MODEL_BASENAME=metamodel
export REPO_NAME=metamodel
export GITHUB_ORGANIZATION=kode-konveyor
export SONAR_ORG=$(GITHUB_ORGANIZATION)
export LANGUAGE=java

all: metamodel.compiled

inputs/metamodel.issues.xml:
	mkdir -p inputs
	touch inputs/metamodel.issues.xml

include /usr/share/zenta-tools/model.rules

clean:
	git clean -fdx
