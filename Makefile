SHELL := /usr/bin/env bash -e -o pipefail

####################################################################################################

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DIST := $(ROOT)dist/

VERSION := $(file < $(ROOT)src/VERSION)

####################################################################################################

.PHONY : tell-version

tell-version :
	@echo $(VERSION)

####################################################################################################

.PHONY : package

package : VERSION.suffix := $(if $(filter %SNAPSHOT,$(VERSION)),-$(shell git rev-parse --short @),)
package : archive := $(DIST)blibmake-$(VERSION)$(VERSION.suffix)
package :
	mkdir -p $(DIST) \
		&& rm -f $(archive)* \
		&& { \
			git ls-tree --full-tree --name-only -r @ src \
				| xargs tar -rvf $(archive).tar --transform 's#^src/#blibmake/#'; \
		} \
		&& gzip -c $(archive).tar > $(archive).tar.gz \
		&& echo $(archive).tar.gz created.

####################################################################################################

.PHONY : clean

clean :
	-rm -rf $(DIST)

####################################################################################################

.PHONY : test

test : tests.dir := $(shell mktemp -d)
test : tests.all := $(shell git ls-files -com --deduplicate --exclude-standard tests | grep 'test_')
test :
	RUNNER_ROOT='$(ROOT)' RUNNER_TESTS='$(tests.all)' RUNNER_DIR='$(tests.dir)' $(ROOT)tests/runner
