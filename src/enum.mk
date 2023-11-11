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
#   # `bmakelib.enum.define(%)`
#
#   Define an enum (aka variant or option.)
#   It can later be used to verify the value of variables by using
#   `bmakelib.enum.error-unless-member`.
#
#   ## Example 1
#
#   Makefile:
#
#       ```Makefile
#       define-enums : bmakelib.enum.define( DaysOfWeek/SUN,MON,TUE,WED,THU,FRI,SAT )
#       define-enums : bmakelib.enum.define( DISTRO/openSUSE,Debian,Fedora)
#       include define-enums
#       ```
#
#   The above makefile defines two enums:
#
#   - `DaysOfWeek` with 7 possible values: `SUN`, `MON`, ...
#   - `DISTRO` with 3 possible values: `openSUSE`, `Debian` and `Fedora`
#
#   💡 _Note the last line in the snippet:  `include`ing a non-PHONY target causes it to be
#   evaluated before any other targets.  We're using this technic to ensure the enums are defined
#   before we access them._
#
#   ## Example 2
#
#   Makefile:
#
#       ```Makefile
#       publish-package : bmakelib.enum.define( PKG-TYPE/deb,rpm,aur)
#	publish-package :
#		...
#	```
#
#   The above snippet defines an enum `PKG-TYPE` with 3 possible values `deb`, `rpm` and `aur`.  The
#   difference with the method used in example 1 is that `PKG-TYPE` is not going to be accessible
#   before `publish-package` is invoked.
#<
####################################################################################################

bmakelib.enum.define(%) :
	$(eval \
		$(eval __enum_name := $(word 1,$(subst $(bmakelib.slash),$(bmakelib.space),$(*)))) \
		$(eval __enum_members_with_comma := $(word 2,$(subst $(bmakelib.slash),$(bmakelib.space),$(*)))) \
		$(eval __enum_members := $(subst $(bmakelib.comma),$(bmakelib.space),$(__enum_members_with_comma))) \
		$(eval __enum_$(__enum_name) := $(__enum_members)))

####################################################################################################
#>
#   # `bmakelib.enum.error-unless-member(%)`
#
#   Verifies if a value is a member of a given enum and aborts make in case if it's not.
#
#   ## Example
#
#   Makefile:
#
#       ```Makefile
#	define-enum : bmakelib.enum.define( DEPLOY-ENV/testing,development,staging,production )
#	include define-enum
#
#       deploy : bmakelib.enum.error-unless-member( DEPLOY-ENV,ENV )
#	deploy :
#		@echo Deploying to $(ENV)...
#	```
#
#   Shell:
#
#	```
#	$ make ENV=local-laptop deploy
#	*** 'local-laptop' is not a member of enum 'DEPLOY-ENV'.  Stop.
#
#       $ make ENV=production deploy
# 	Deploying to production...
#
#<
####################################################################################################

bmakelib.enum.error-unless-member(%) :
	$(eval \
		$(eval __enum_name := $(word 1,$(subst $(bmakelib.comma),$(bmakelib.space),$(*)))) \
		$(eval __var_name := $(word 2,$(subst $(bmakelib.comma),$(bmakelib.space),$(*)))) \
		$(if $(filter $($(__var_name)),$(__enum_$(__enum_name))),\
			,\
			$(error '$($(__var_name))' is not a member of enum '$(__enum_name)')))
