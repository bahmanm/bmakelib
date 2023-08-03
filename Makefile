SHELL := /bin/bash

####################################################################################################

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

VERSION := $(file < $(ROOT)src/VERSION)

####################################################################################################

.PHONY : tell-version

tell-version :
	@echo $(VERSION)
