# Copyright © Bahman Movaqar
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

SHELL := /usr/bin/env -S bash -o pipefail
.DEFAULT_GOAL := test

####################################################################################################

export ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
URL := https://github.com/bahmanm/bmakelib
NAME := bmakelib
VERSION ?= development
PKG_VERSION = $(subst -,~,$(VERSION))
DEB_MAINTAINER_NAME ?= $(or $(shell git config user.name 2>/dev/null),Bahman Movaqar)
DEB_MAINTAINER_EMAIL ?= $(or $(shell git config user.email 2>/dev/null),Bahman@BahmanM.com)
BUILD := $(ROOT)_build/
RPMBUILD := $(BUILD)rpmbuild/
RPMSPEC := $(RPMBUILD)SPECS/bmakelib.spec
DEBBUILD := $(BUILD)debbuild/
STAGE := $(BUILD)stage/
DIST := $(ROOT)dist/

####################################################################################################

$(BUILD) :
	mkdir -p $(BUILD)

####################################################################################################

$(DIST) :
	mkdir -p $(DIST)

####################################################################################################

$(BUILD)$(NAME)-$(PKG_VERSION).src.tar.gz : $(BUILD)
$(BUILD)$(NAME)-$(PKG_VERSION).src.tar.gz :
	tar --create --gzip \
		--file=$(@) \
		--directory=$(ROOT) \
		--transform='s#^\.#$(NAME)-$(PKG_VERSION)#' \
		$(shell xargs -I{} echo "--exclude='{}'" < .gitignore) \
		.

####################################################################################################

define _install-to
	install -m u=rwx,g=rx,o=rx -d $(1)/include/$(NAME) \
	&& install -m u=rwx,g=rx,o=rx -d $(1)/share/doc/$(NAME) \
	&& find $(BUILD)include -type f -exec install -m u=rw,g=r,o=r {} $(1)/include/$(NAME) \; \
	&& install -m u=rw,g=r,o=r $(BUILD)include/VERSION $(BUILD)doc/LICENSE $(1)/share/doc/$(NAME) \
	&& find $(BUILD)doc -type f -name '*.md' -exec install -m u=rw,g=r,o=r {} $(1)/share/doc/$(NAME) \;
endef

####################################################################################################

$(DIST)$(NAME)-$(VERSION)-portable.tar.gz : $(DIST)
$(DIST)$(NAME)-$(VERSION)-portable.tar.gz : build
	rm -rf $(STAGE) \
	&& $(call _install-to,$(STAGE)$(NAME)-$(VERSION)) \
	&& tar --create --gzip \
		--file=$(@) \
		--directory=$(STAGE) \
		$(NAME)-$(VERSION)

####################################################################################################

.PHONY : package-portable

package-portable : $(DIST)$(NAME)-$(VERSION)-portable.tar.gz

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

package-rpm._preprocess : $(BUILD)$(NAME)-$(PKG_VERSION).src.tar.gz
package-rpm._preprocess : $(RPMBUILD) $(RPMSPEC)
package-rpm._preprocess :
	cp $(BUILD)$(NAME)-$(PKG_VERSION).src.tar.gz $(RPMBUILD)SOURCES/$(NAME)-$(PKG_VERSION).tar.gz \
	&& perl -pi \
		-E 's#(Version:\s*).+#$${1}$(PKG_VERSION)#;' \
		-E 's#(Source0:\s*).+#$${1}$(NAME)-$(PKG_VERSION).tar.gz#;' \
		$(RPMSPEC)

####################################################################################################

.PHONY : package-rpm._run-rpmbuild-env

package-rpm._run-rpmbuild-env :
	docker build -t $(NAME)-rpmbuild-env - < $(ROOT)pkg/rpmbuild-env.Dockerfile \
	&& docker run --rm -v $(ROOT):/project $(NAME)-rpmbuild-env make package-rpm._build VERSION=$(VERSION)

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

package-deb._preprocess : $(BUILD)$(NAME)-$(PKG_VERSION).src.tar.gz
package-deb._preprocess : $(DEBBUILD)
package-deb._preprocess :
	cp $(BUILD)$(NAME)-$(PKG_VERSION).src.tar.gz $(DEBBUILD)$(NAME)_$(PKG_VERSION).orig.tar.gz  \
	&& tar -C $(DEBBUILD) -xzf $(BUILD)$(NAME)-$(PKG_VERSION).src.tar.gz \
	&& cp -r $(ROOT)pkg/debian $(DEBBUILD)$(NAME)-$(PKG_VERSION) \
	&& DATE=$$(date +'%a, %d %b %Y %H:%M:%S %z') \
	DEB_MAINTAINER_NAME="$(DEB_MAINTAINER_NAME)" \
	DEB_MAINTAINER_EMAIL="$(DEB_MAINTAINER_EMAIL)" \
	perl -pi \
		-E 's/%VERSION%/$(PKG_VERSION)/;' \
		-E 's/%DISTRO%/unstable/;' \
		-E 's/%GIT_USER%/$$ENV{"DEB_MAINTAINER_NAME"}/;' \
		-E 's/%GIT_EMAIL%/$$ENV{"DEB_MAINTAINER_EMAIL"}/;' \
		-E 's/%DATE%/$$ENV{"DATE"}/' \
		$(DEBBUILD)$(NAME)-$(PKG_VERSION)/debian/changelog

####################################################################################################

.PHONY : package-deb._run-debbuild-env

package-deb._run-debbuild-env :
	docker build -t $(NAME)-debbuild-env - < $(ROOT)pkg/debbuild-env.Dockerfile \
	&& docker run --rm -v $(ROOT):/project $(NAME)-debbuild-env make package-deb._build VERSION=$(VERSION)

####################################################################################################

.PHONY : package-deb._build

package-deb._build :
	cd $(DEBBUILD)$(NAME)-$(PKG_VERSION) \
	&& debuild \
		--preserve-envvar=PATH \
		--no-tgz-check \
		-us -uc -F

####################################################################################################

.PHONY : package-deb._postprocess

package-deb._postprocess :
	cp \
		$(DEBBUILD)$(NAME)_$(PKG_VERSION).orig.tar.gz \
		$(DEBBUILD)$(NAME)_$(PKG_VERSION)-*.debian.tar.xz \
		$(DEBBUILD)$(NAME)_$(PKG_VERSION)-*.dsc \
		$(DEBBUILD)$(NAME)_$(PKG_VERSION)-*_all.deb \
		$(DIST)

####################################################################################################

.PHONY : package-deb

package-deb : package-deb._preprocess
package-deb : package-deb._run-debbuild-env
package-deb : package-deb._postprocess

####################################################################################################

.PHONY : package

package : package-portable
package : package-rpm
package : package-deb

####################################################################################################

.PHONY : build

build : $(BUILD)
build : test
build : doc-update
build :
	mkdir -p $(BUILD)include $(BUILD)doc \
	&& find src -type f \( -name '*.mk' -or -name '*.pl' \) -exec cp {} $(BUILD)/include/ \; \
	&& echo "$(VERSION)" > $(BUILD)include/VERSION \
	&& cp \
		$(ROOT)LICENSE \
		$(ROOT)README.md \
		$(ROOT)doc/*.md \
		$(BUILD)doc

####################################################################################################

PREFIX ?= $(DESTDIR)/usr

.PHONY : install

install : build
install :
	$(call _install-to,$(PREFIX))

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

####################################################################################################

.PHONY : doc-update

doc-update :
	cd $(ROOT)src \
	&& find * -type f -name '*.mk' -exec $(ROOT)doc/update {} \;
