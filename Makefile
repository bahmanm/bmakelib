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
