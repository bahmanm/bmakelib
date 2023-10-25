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
#   # `bmakelib.error-if-blank(%)`
#
#   Fails make with an error message if the provided variable(s) are blank.
#
#   ## Example
#
#   Makefile:
#
#	```Makefile
#	VAR1 =
#	VAR2 = 100
#	some-target : bmakelib.error-if-blank( VAR1 VAR2 )
#	```
#
#   Shell:
#
#	```
#	$ make some-target
#	*** Provide value for 'VAR1'.  Stop.
#	```
#<
####################################################################################################

bmakelib.error-if-blank(%) :
	$(if $($(*)), \
		, \
		$(error Provide a value for '$(*)'))
