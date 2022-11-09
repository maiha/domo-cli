SHELL=/bin/bash

export GNUMAKEFLAGS=--no-print-directory
.SHELLFLAGS = -o pipefail -c

all: compile

######################################################################
### compiling

export LC_ALL=C
export UID = $(shell id -u)
export GID = $(shell id -g)

BUILD_TARGET=
COMPILE_FLAGS=-Dstatic
DOCKER := docker compose run crystal

compile: domo-cli-dev

.PHONY: build
build:
	@$(DOCKER) shards build $(COMPILE_FLAGS) --link-flags "-static" $(BUILD_TARGET) $(O)

.PHONY: domo-cli-dev
domo-cli-dev: BUILD_TARGET=domo-cli-dev
domo-cli-dev: build

.PHONY: domo-cli
domo-cli: BUILD_TARGET=--release domo-cli
domo-cli: build
	@md5sum bin/$@

.PHONY: console
console:
	@$(DOCKER) sh

.PHONY: clean
clean:
	rm -rf bin lib .crystal .shards tmp

######################################################################
### testing

.PHONY: ci
ci: compile test

test: test/unit

test/%: bin/domo-cli-dev
	@rm -rf tmp && mkdir tmp
	@cd tmp && ln -s ../$< domo-cli && ln -s ../tests/Makefile
	@make $* -C tmp

######################################################################
### versioning

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1)
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.PHONY : version
version:
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
