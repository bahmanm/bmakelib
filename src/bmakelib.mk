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

####################################################################################################
#>
#   # `bmakelib.MIN_MAKE_VERSION`
#
#   Minimum Make version supported.
#
#   Anything older either breaks bmakelib or can cause it to behave in unexpected ways.
#<
####################################################################################################

bmakelib.MIN_MAKE_VERSION := 4.4

####################################################################################################
#>
#   # `bmakelib.newline`
#
#   Expands to a single newline (\n)
#<
####################################################################################################

define bmakelib.newline :=


endef

####################################################################################################
#>
#   # `bmakelib.comma`
#
#   Expands to a comma (,)
#<
####################################################################################################

bmakelib.comma := ,

####################################################################################################
#>
#   # `bmakelib.slash`
#
#   Expands to a slash (/)
#<
####################################################################################################

bmakelib.slash := /

####################################################################################################
#>
#   # `bmakelib.backslash`
#
#   Expands to a backslash (\)
#<
####################################################################################################

bmakelib.backslash := $(subst ,\,)

####################################################################################################
#>
#   # `bmakelib.space`
#
#   Expands to a whitespace
#<
####################################################################################################

bmakelib.space := $(subst , ,)

####################################################################################################
#   Abort with, hopefully, an informative message if it's an unsupported Make version.
####################################################################################################

ifeq ($(shell perl -E 'print $$1 if "$(MAKE_VERSION)" =~ /^\s*(\d+(\.\d+)?)/ && $$1 >= $(bmakelib.MIN_MAKE_VERSION)'),)

# Expands to 8 consequtive spaces
bmakelib.octospace := $(subst ,        ,)

# Abort
$(error \
❌ Incompatible Make version.$(bmakelib.newline)\
The minimum Make version supported by bmakelib is $(bmakelib.MIN_MAKE_VERSION) while you are $(bmakelib.newline)\
running $(MAKE_VERSION).$(bmakelib.newline)$(bmakelib.newline)\
\
bmakelib has aborted the make process in order to avoid unexpected$(bmakelib.newline)\
behaviours and hard to find bugs.$(bmakelib.newline)$(bmakelib.newline)\
\
💡 Please upgrade to a more$(bmakelib.newline)\ modern Make. On most platforms, upgrading is as\
simple as running $(bmakelib.newline)$(bmakelib.newline)\
\
\
$(bmakelib.octospace)wget 'https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz' $(bmakelib.backslash)$(bmakelib.newline) \
$(bmakelib.octospace)&& tar xzf make-4.4.1.tar.gz                          $(bmakelib.backslash)$(bmakelib.newline) \
$(bmakelib.octospace)&& cd make-4.4.1                                      $(bmakelib.backslash)$(bmakelib.newline) \
$(bmakelib.octospace)&& ./configure --prefix=/usr/local                    $(bmakelib.backslash)$(bmakelib.newline) \
$(bmakelib.octospace)&& sudo make install$(bmakelib.newline)$(bmakelib.newline))

endif

####################################################################################################
#   If it's a supported Make version, include the rest of bmakelib suite.
####################################################################################################

export bmakelib.ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
export bmakelib.VERSION := $(file < $(bmakelib.ROOT)VERSION)

####################################################################################################

bmakelib.FEATURES := error-if-blank.mk default-if-blank.mk timed.mk logged.mk enum.mk

.PHONY : $(bmakelib.FEATURES:%=$(bmakelib.ROOT)%)

include $(bmakelib.FEATURES:%=$(bmakelib.ROOT)%)
