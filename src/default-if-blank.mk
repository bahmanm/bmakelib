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
#   # `bmakelib.default-if-blank(%)`
#
#   If the given variable(s) is blank, sets its value to the provided default.
#   It will also emit an "info" message if the value of `bmakelib.conf.default-if-blank.SILENT` is
#   "no".
#
#
#   ## Notes:
#
#   Currently there's no way to pass a value which contains spaces for a variable.  That is, the
#   following will have undesired effects:
#
#	```Makefile
#	some-target : bmakelib.default-if-blank( VAR1,hello world )
#	```
#
#   ##  Example 1
#
#   Makefile:
#
#	```Makefile
#	VAR1 =
#	VAR2 = 100
#	some-target : bmakelib.default-if-blank( VAR1,foo VAR2,bar )
#		@echo $(VAR1), $(VAR2)
#	```
#
#   Shell:
#
#	```
#	$ make some-target
#	foo, 100
#	```
#
#   ##  Example 2
#
#   Makefile:
#
#	```Makefile
#	some-target : bmakelib.default-if-blank( VAR1,foo )
#		@echo $(VAR1)
#	```
#
#   Shell:
#
#	```
#	$ make bmakelib.conf.default-if-blank.SILENT=no some-target
#	Using default value 'foo' for variable 'VAR1'.
#	foo
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
#   Default is "yes" which means do NOT emit.
#   Set to "no" to make it behave otherwise.
#<
####################################################################################################

bmakelib.conf.default-if-blank.SILENT ?= yes
