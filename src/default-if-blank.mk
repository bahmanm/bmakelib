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
#   # `bmakelib.default-if-blank`
#
#   If the given variable is blank, sets its value to the provided default.
#
#   ###  Example 1
#
#   Makefile:
#
#	```Makefile
#	VAR1 =
#	VAR2 = 100
#	some-target : bmakelib.default-if-blank( VAR1,foo VAR2,bar )
#		@echo 👉 VAR1=$(VAR1), VAR2=$(VAR2)
#	```
#
#   Shell:
#
#	```text
#	$ make some-target
#	👉 VAR1=foo, VAR2=100
#	```
#
#   ###  Example 2
#
#   Makefile:
#
#	```Makefile
#	some-target : bmakelib.default-if-blank( VAR1,foo )
#		@echo ✅ VAR1 is $(VAR1)
#	```
#
#   Shell:
#
#	```text
#	$ make bmakelib.conf.default-if-blank.SILENT=no some-target
#	Using default value 'foo' for variable 'VAR1'.
#	✅ VAR1 is foo
#	```
#
#   ### Notes:
#
#   * Set `bmakelib.conf.default-if-blank.SILENT` to "no" to emit an `info` message when using
#   the default value.
#
#   * Currently there's no way to pass a value which contains spaces for a variable.  That is, the
#     following will have undesired effects:
#
#	```Makefile
#	some-target : bmakelib.default-if-blank( VAR1,hello world )
#	```
#<
####################################################################################################

bmakelib.default-if-blank(%) :
	$(let _varname _varval _rest, \
		$(subst $(bmakelib.comma), ,$(*)), \
		$(if $($(_varname)), \
			, \
			$(if $(filter yes,$(bmakelib.conf.default-if-blank.SILENT)), \
				, \
				$(info Using default value '$(_varval)' for variable '$(_varname)')) \
			$(eval override $(_varname) := $(_varval))))

####################################################################################################
#>
#   # `bmakelib.conf.default-if-blank.SILENT`
#
#   Controls whether `bmakelib.default-if-blank` should emit an info message when using the default
#   provided.
#
#   Precedence:
#     1. `bmakelib.conf.default-if-blank.SILENT` (Make variable)
#     2. `BMAKELIB_CONF_DEFAULT_IF_BLANK_SILENT` (environment variable)
#     3. `yes` (default)
#<
####################################################################################################

bmakelib.conf.default-if-blank.SILENT ?= $(or $(BMAKELIB_CONF_DEFAULT_IF_BLANK_SILENT),yes)
