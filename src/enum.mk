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

####################################################################################################
#>
#   # `bmakelib.enum.define`
#
#   Defines an enum (aka variant or option.)
#
#   It can later be used to verify the value of variables by using
#   `bmakelib.enum.error-unless-member`.
#
#   There are two variations to this feature.
#   - as a target dependency
#   - as a variable (macro)
#
#   Both produce the same results.  Except some minor cases, choice of the variation is mostly a
#   matter of style.
#
#   ### Example 1
#
#   Makefile using target dependency:
#
#	```Makefile
#	define-enums : bmakelib.enum.define( DaysOfWeek/SUN,MON,TUE,WED,THU,FRI,SAT )
#	define-enums : bmakelib.enum.define( DISTRO/openSUSE,Debian,Fedora )
#	include define-enums
#	```
#
#   Or Makefile using variable (macro):
#
#	```Makefile
#	$(call bmakelib.enum.define,DaysOfWeek/SUN,MON,TUE,WED,THU,FRI,SAT)
#	$(call bmakelib.enum.define,DISTRO/openSUSE,Debian,Fedora)
#	```
#
#   Either of the above makefiles defines two enums:
#
#   - `DaysOfWeek` with 7 possible values: `SUN`, `MON`, ...
#   - `DISTRO` with 3 possible values: `openSUSE`, `Debian` and `Fedora`
#
#   💡 _Note the last line in the first snippet:  `include`ing a non-PHONY target causes it to be
#   evaluated before any other targets.  We're using this technic to ensure the enums are defined
#   before we access them._
#
#   ### Example 2
#
#   Makefile using target dependency:
#
#	```Makefile
#	publish-package : bmakelib.enum.define( PKG-TYPE/deb,rpm,aur)
#	publish-package :
#		...
#	```
#
#   Or Makefile using variable (macro):
#
#	```Makefile
#	$(call bmakelib.enum.define,PKG-TYPE/deb,rpm,aur)
#	```
#
#   Either of the above snippets defines an enum `PKG-TYPE` with 3 possible values `deb`, `rpm`
#   and `aur`.
#
#   _In case of the the first snippet (using target dependency), the difference with the method used
#   in example 1 is that `PKG-TYPE` would not be accessible before `publish-package` is invoked._
#<
####################################################################################################

bmakelib.enum.define(%) :
	$(eval \
		$(eval __enum_name := $(word 1,$(subst $(bmakelib.slash),$(bmakelib.space),$(*)))) \
		$(eval __enum_members_with_comma := $(word 2,$(subst $(bmakelib.slash),$(bmakelib.space),$(*)))) \
		$(eval __enum_members := $(subst $(bmakelib.comma),$(bmakelib.space),$(__enum_members_with_comma))) \
		$(eval __enum_$(__enum_name) := $(__enum_members)))

define bmakelib.enum.define
$(eval \
	$(eval __enum_name := $(word 1,$(subst $(bmakelib.slash),$(bmakelib.space),$(1)))) \
	$(eval __enum_members := $(word 2,$(subst $(bmakelib.slash),$(bmakelib.space),$(1))) $(2) $(3) $(4) $(5) $(6) $(7) $(8) $(9) $(10)) \
	$(eval __enum_$(__enum_name) := $(__enum_members)))
endef

####################################################################################################
#>
#   # `bmakelib.enum.error-unless-member`
#
#   Verifies if a variable's value is a member of a given enum and aborts make in case it's not.
#
#   _Note that just like `bmakelib.enum.define`, there are two variations of `error-unless-member`._
#
#   ### Example 1
#
#   Makefile:
#
#	```Makefile
#	$(call bmakelib.enum.define,DEPLOY-ENV/development,staging,production)
#
#	deploy : bmakelib.enum.error-unless-member( DEPLOY-ENV,ENV )
#	deploy :
#		@echo 🚀 Deploying to $(ENV)...
#	```
#
#   Shell:
#
#	```text
#	$ make ENV=local-laptop deploy
#	*** 'local-laptop' is not a member of enum 'DEPLOY-ENV'.  Stop.
#
#	$ make ENV=production deploy
#	🚀 Deploying to production...
#	```
#
#   ### Example 2
#
#   Makefile:
#
#	```Makefile
#	define-enum : bmakelib.enum.define( BUILD-TARGET/android,ios,linux )
#	include define-enum
#
#	deploy :
#		$(call bmakelib.enum.error-unless-member,BUILD-TARGET,TARGET)
#		@echo 🏭 Building for $(TARGET)...
#	```
#
#   Shell:
#
#	```text
#	$ make TARGET=windows deploy
#	*** 'windows' is not a member of enum 'BUILD-TARGET'.  Stop.
#
#	$ make TARGET=ios deploy
#	🏭 building for ios...
#	```
#<
####################################################################################################

bmakelib.enum.error-unless-member(%) :
	$(eval \
		$(eval __enum_name := $(word 1,$(subst $(bmakelib.comma),$(bmakelib.space),$(*)))) \
		$(eval __var_name := $(word 2,$(subst $(bmakelib.comma),$(bmakelib.space),$(*)))) \
		$(if $(filter $($(__var_name)),$(__enum_$(__enum_name))),\
			,\
			$(error '$($(__var_name))' is not a member of enum '$(__enum_name)')))

define bmakelib.enum.error-unless-member
$(eval \
	$(if $(filter $($(2)),$(__enum_$(1))),\
		,\
		$(error '$($(2))' is not a member of enum '$(1)')))
endef
