# Copyright © 2023 Bahman Movaqar
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
####################################################################################################

SHELL := /usr/bin/env bash -e -o pipefail
.DEFAULT_GOAL := test

####################################################################################################

export ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
URL := https://github.com/bahmanm/bmakelib
NAME := bmakelib
VERSION = $(file < $(ROOT)src/VERSION)
BUILD := $(ROOT)_build/
RPMBUILD := $(BUILD)rpmbuild/
RPMSPEC := $(RPMBUILD)SPECS/bmakelib.spec
DIST := $(ROOT)dist/

####################################################################################################

$(BUILD) :
	mkdir -p $(BUILD)

####################################################################################################

$(DIST) :
	mkdir -p $(DIST)

####################################################################################################

$(DIST)$(NAME)-$(VERSION).tar.gz : $(DIST)
$(DIST)$(NAME)-$(VERSION).tar.gz :
	tar --create --gzip \
		--file=$(@) \
		--directory=$(ROOT) \
		--transform='s#^\.#$(NAME)-$(VERSION)#' \
		$(shell xargs -I{} echo "--exclude='{}'" < .gitignore) \
		.

####################################################################################################

$(RPMSPEC) : $(RPMBUILD)
$(RPMSPEC) :
	cp $(ROOT)pkg/$(NAME).spec $(RPMBUILD)SPECS

####################################################################################################

$(RPMBUILD) : $(BUILD)
$(RPMBUILD) :
	mkdir -p $(RPMBUILD){BUILD,BUILDROOT,SOURCES,RPMS,SPECS,SRPMS}

####################################################################################################

.PHONY : package-rpm._preprocess

package-rpm._preprocess : $(DIST)$(NAME)-$(VERSION).tar.gz
package-rpm._preprocess : $(RPMBUILD) $(RPMSPEC)
package-rpm._preprocess :
	cp $(DIST)$(NAME)-$(VERSION).tar.gz $(RPMBUILD)SOURCES
	summary="$$(perl -nE 'print if $$. == 2' < $(ROOT)README.md)" \
	source1='$(URL)/archive/refs/tags/v$(VERSION).tar.gz' \
	description="$${summary}  Souce archive available at $${source1}" \
	perl -pi \
		-E 's/%{version}/$(VERSION)/;' \
		-E 's/(Version:\s*).+/$${1}$(VERSION)/;' \
		-E 's/%{summary}/$$ENV{summary}/;' \
		-E 's/(Summary:\s*).+/$$1$$ENV{summary}/;' \
		-E 's/%{source0}/$(NAME)-$(VERSION).tar.gz/;' \
		-E 's/(Source0:\s*).+/$$1$(NAME)-$(VERSION).tar.gz/;' \
		$(RPMSPEC)

####################################################################################################

.PHONY : package-rpm._run-rpmbuild-env

package-rpm._run-rpmbuild-env :
	docker build -t $(NAME)-rpmbuild-env - < $(ROOT)pkg/rpmbuild-env.Dockerfile
	docker run --rm -v $(ROOT):/project $(NAME)-rpmbuild-env make package-rpm._build

####################################################################################################

.PHONY : package-rpm._build

package-rpm._build :
	rpmdev-bumpspec -r $(RPMSPEC)
	rpmbuild \
		--define='_topdir $(RPMBUILD)' \
		--define='source0 $(URL)/archive/refs/tags/v$(VERSION).tar.gz' \
		-ba $(RPMSPEC)

####################################################################################################

.PHONY : package-rpm._postprocess

package-rpm._postprocess :
	cp $(RPMBUILD)RPMS/noarch/*.rpm $(RPMBUILD)SRPMS/*.rpm $(DIST)
	cp $(RPMSPEC) $(ROOT)/pkg

####################################################################################################

.PHONY : package-rpm

package-rpm : package-rpm._preprocess
package-rpm : package-rpm._run-rpmbuild-env
package-rpm : package-rpm._postprocess

####################################################################################################

.PHONY : build

build : $(BUILD)
build : test
build :
	mkdir -p $(BUILD)include
	find src -type f \( -name '*.Makefile' -or -name 'VERSION' \) -exec cp {} $(BUILD)/include/ \;
	mkdir -p $(BUILD)doc
	cp LICENSE src/VERSION $(BUILD)doc

####################################################################################################

PREFIX ?= /usr/local

.PHONY : install

install : build
install :
	install --mode=u=rwx,g=rx,o=rx -d $(PREFIX)/include/$(NAME)
	install --mode=u=rwx,g=rx,o=rx -d $(PREFIX)/doc/$(NAME)
	find $(BUILD)include -type f -exec install --mode=u=rw,g=r,o=r {} $(PREFIX)/include/$(NAME) \;
	install --mode=u=rw,g=r,o=r $(BUILD)include/VERSION $(BUILD)doc/LICENSE $(PREFIX)/doc/$(NAME)

####################################################################################################

.PHONY : clean

clean :
	-rm -rf $(BUILD) $(DIST)

####################################################################################################

.PHONY : test

test : export bmakelib.ROOT := $(ROOT)src/
test : tests.dir := $(shell mktemp -d)
test : tests.all := $(shell find tests -type f \
				\( -name 'test_*' $(shell xargs -I{} echo "! -name '{}'" < .gitignore ) \))
test :
	RUNNER_ROOT='$(ROOT)' RUNNER_TESTS='$(tests.all)' RUNNER_DIR='$(tests.dir)' $(ROOT)tests/runner
