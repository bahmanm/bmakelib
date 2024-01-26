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

SHELL := /usr/bin/env -S bash -e -o pipefail --login
.DEFAULT_GOAL := test

####################################################################################################

export ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
URL := https://github.com/bahmanm/bmakelib
NAME := bmakelib
VERSION = $(file < $(ROOT)src/VERSION)
BUILD := $(ROOT)_build/
RPMBUILD := $(BUILD)rpmbuild/
RPMSPEC := $(RPMBUILD)SPECS/bmakelib.spec
DEBBUILD := $(BUILD)debbuild/
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
	cp $(DIST)$(NAME)-$(VERSION).tar.gz $(RPMBUILD)SOURCES \
	&& perl -pi \
		-E 's#(Version:\s*).+#$${1}$(VERSION)#;' \
		-E 's#(Source0:\s*).+#$${1}$(NAME)-$(VERSION).tar.gz#;' \
		$(RPMSPEC)

####################################################################################################

.PHONY : package-rpm._run-rpmbuild-env

package-rpm._run-rpmbuild-env :
	docker build -t $(NAME)-rpmbuild-env - < $(ROOT)pkg/rpmbuild-env.Dockerfile \
	&& docker run --rm -v $(ROOT):/project $(NAME)-rpmbuild-env make package-rpm._build

####################################################################################################

.PHONY : package-rpm._build

package-rpm._build :
	rpmdev-bumpspec -r $(RPMSPEC) \
	&& rpmbuild \
		--define='_topdir $(RPMBUILD)' \
		--define='source0 $(URL)/archive/refs/tags/v$(VERSION).tar.gz' \
		-ba $(RPMSPEC)

####################################################################################################

.PHONY : package-rpm._postprocess

package-rpm._postprocess :
	cp $(RPMBUILD)RPMS/noarch/*.rpm $(RPMBUILD)SRPMS/*.rpm $(DIST)

####################################################################################################

.PHONY : package-rpm

package-rpm : package-rpm._preprocess
package-rpm : package-rpm._run-rpmbuild-env
package-rpm : package-rpm._postprocess

####################################################################################################

$(DEBBUILD) :
	mkdir -p $(DEBBUILD)

####################################################################################################

.PHONY : package-deb._preprocess

package-deb._preprocess : $(DIST)$(NAME)-$(VERSION).tar.gz
package-deb._preprocess : $(DEBBUILD)
package-deb._preprocess :
	cp $(DIST)$(NAME)-$(VERSION).tar.gz $(DEBBUILD)$(NAME)_$(VERSION).orig.tar.gz  \
	&& tar -C $(DEBBUILD) -xzf $(DIST)$(NAME)-$(VERSION).tar.gz \
	&& cp -r $(ROOT)pkg/debian $(DEBBUILD)$(NAME)-$(VERSION) \
	&& DATE=$$(date +'%a, %d %b %Y %H:%M:%S %z') \
	USER=$$(git config user.name) \
	EMAIL=$$(git config user.email) \
	perl -pi \
		-E 's/%VERSION%/$(VERSION)/;' \
		-E 's/%DISTRO%/unstable/;' \
		-E 's/%GIT_USER%/$$ENV{"USER"}/;' \
		-E 's/%GIT_EMAIL%/$$ENV{"EMAIL"}/;' \
		-E 's/%DATE%/$$ENV{"DATE"}/' \
		$(DEBBUILD)$(NAME)-$(VERSION)/debian/changelog

####################################################################################################

.PHONY : package-deb._run-debbuild-env

package-deb._run-debbuild-env :
	docker build -t $(NAME)-debbuild-env - < $(ROOT)pkg/debbuild-env.Dockerfile \
	&& docker run --rm -v $(ROOT):/project $(NAME)-debbuild-env make package-deb._build

####################################################################################################

.PHONY : package-deb._build

package-deb._build :
	cd $(DEBBUILD)$(NAME)-$(VERSION) \
	&& debuild \
		--preserve-envvar=PATH \
		--no-tgz-check \
		-us -uc -F

####################################################################################################

.PHONY : pakacge-dev._postprocess

package-deb._postprocess :
	cp \
		$(DEBBUILD)$(NAME)_$(VERSION).orig.tar.gz \
		$(DEBBUILD)$(NAME)_$(VERSION)-*.debian.tar.xz \
		$(DEBBUILD)$(NAME)_$(VERSION)-*.dsc \
		$(DEBBUILD)$(NAME)_$(VERSION)-*_all.deb \
		$(DIST)

####################################################################################################

.PHONY : package-deb

package-deb : package-deb._preprocess
package-deb : package-deb._run-debbuild-env
package-deb : package-deb._postprocess

####################################################################################################

.PHONY : build

build : $(BUILD)
build : test
build : doc-update
build :
	mkdir -p $(BUILD)include \
	&& find src -type f \( -name '*.mk' -or -name 'VERSION' \) -exec cp {} $(BUILD)/include/ \; \
	&& mkdir -p $(BUILD)doc \
	&& cp \
		$(ROOT)LICENSE \
		$(ROOT)src/VERSION \
		$(ROOT)README.md \
		$(ROOT)doc/*.md \
		$(BUILD)doc

####################################################################################################

PREFIX ?= $(DESTDIR)/usr

.PHONY : install

install : build
install :
	install -m u=rwx,g=rx,o=rx -d $(PREFIX)/include/$(NAME) \
	&& install -m u=rwx,g=rx,o=rx -d $(PREFIX)/share/doc/$(NAME) \
	&& find $(BUILD)include -type f -exec install -m u=rw,g=r,o=r {} $(PREFIX)/include/$(NAME) \; \
	&& install -m u=rw,g=r,o=r $(BUILD)include/VERSION $(BUILD)doc/LICENSE $(PREFIX)/share/doc/$(NAME) \
	&& find $(BUILD)doc -type f -name '*.md' -exec install -m u=rw,g=r,o=r {} $(PREFIX)/share/doc/$(NAME) \;

####################################################################################################

.PHONY : clean

clean :
	-rm -rf $(BUILD) $(DIST)

####################################################################################################

.PHONY : test

test : export bmakelib.ROOT := $(ROOT)src/
test : tests.thing1 := thing1
test : tests.dir := $(shell mktemp -d)
test : tests.all := $(shell find tests -type f \
				\( -name 'test_*' $(shell xargs -I{} echo "! -name '{}'" < .gitignore ) \))
test : tests.thing2 := thing2
test :
	RUNNER_ROOT='$(ROOT)' RUNNER_TESTS='$(tests.all)' RUNNER_DIR='$(tests.dir)' THING1=$(tests.thing1) THING2=$(tests.thing2) $(ROOT)tests/runner

####################################################################################################

.PHONY : doc-update

doc-update :
	cd $(ROOT)src \
	&& find * -type f -name '*.mk' -exec $(ROOT)doc/update {} \;
