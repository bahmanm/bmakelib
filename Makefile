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

NAME := bmakelib
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
package : archive := $(DIST)$(NAME)-$(VERSION)$(VERSION.suffix)
package :
	mkdir -p $(DIST) \
		&& rm -f $(archive)* \
		&& { \
			git ls-tree --full-tree --name-only -r @ src \
				| xargs tar -rvf $(archive).tar --transform 's#^src/#$(NAME)/#'; \
		} \
		&& tar -rvf $(archive).tar --transform 's#^#bmakelib/#' LICENSE \
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

####################################################################################################

.PHONY : _tell-make-features

_tell-make-features :
	@echo Make faetures enabled: "$(.FEATURES)"

####################################################################################################

.PHONY : _tell-make-version

_tell-make-version :
	@echo Make version: "$(MAKE_VERSION)"

####################################################################################################

.PHONY : tell-make-version

tell-make-version : _tell-make-version _tell-make-features

####################################################################################################

.PHONY : test-in-containers

test-in-containers : image.2204 := bmakelib-tests-ubuntu-22-04:latest
test-in-containers :
	@docker build -t $(image.2204) - < $(ROOT)tests/ubuntu-22.04.Dockerfile
	@docker run -v $(ROOT):/bmakelib --rm $(image.2204)
