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

.PHONY : _bmakelib.help.noop

_bmakelib.help.noop :

####################################################################################################
#>
#   # `bmakelib.help`
#
#   Extracts and displays available targets and variables along with their documentation.
#
#   ### Example
#
#   Makefile:
#
#	```Makefile
#	build: ## Compile and package all build artefacts
#	PREFIX ?= /usr ## Base installation prefix directory
#	```
#
#   Shell:
#
#	```text
#	$ make bmakelib.help
#	================================================================================
#	  LOCAL
#	================================================================================
#
#	  TARGETS
#	    build   Compile and package all build artefacts
#
#	  VARIABLES
#	    PREFIX  Base installation prefix directory
#	```
#<
####################################################################################################

.PHONY : bmakelib.help

bmakelib.help :
	@env -i \
		PATH="$$PATH" \
		HOME="$$HOME" \
		ROOT="$(ROOT)" \
		bmakelib.ROOT="$(bmakelib.ROOT)" \
		$(MAKE) -p -q -n _bmakelib.help.noop \
	| perl $(bmakelib.ROOT)help.pl \
		"$(or $(ROOT),./)" \
		"$(bmakelib.conf.help.targets)" \
		"$(bmakelib.conf.help.variables)" \
		"$(bmakelib.conf.help.scope)" \
		"$(bmakelib.conf.help.tips)"

####################################################################################################
#>
#   # `bmakelib.conf.help.convenience-target`
#
#   Whether to define the convenience target `help`.
#   Set to 'no' *before* including bmakelib to disable.
#
#   Precedence:
#     1. `bmakelib.conf.help.convenience-target` (Make variable)
#     2. `BMAKELIB_CONF_HELP_CONVENIENCE_TARGET` (environment variable)
#     3. `yes` (default)
#<
####################################################################################################

bmakelib.conf.help.convenience-target ?= $(or $(BMAKELIB_CONF_HELP_CONVENIENCE_TARGET),yes)

####################################################################################################
#>
#   # `help`
#
#   Convenience target with a shorter and more intuitive name.  It's a drop-in replacement for
#   `bmakelib.help`.
#
#   See also `bmakelib.conf.help.convenience-target`.
#<
####################################################################################################

ifneq ($(bmakelib.conf.help.convenience-target),no)

.PHONY : help

help : bmakelib.help

endif

####################################################################################################
#>
#   # `bmakelib.conf.help.targets`
#
#   Controls whether `bmakelib.help` should render target definitions.
#
#   Precedence:
#     1. `bmakelib.conf.help.targets` (Make variable)
#     2. `BMAKELIB_CONF_HELP_TARGETS` (environment variable)
#     3. `yes` (default)
#<
####################################################################################################

bmakelib.conf.help.targets ?= $(or $(BMAKELIB_CONF_HELP_TARGETS),yes)

####################################################################################################
#>
#   # `bmakelib.conf.help.variables`
#
#   Controls whether `bmakelib.help` should render variable definitions.
#
#   Precedence:
#     1. `bmakelib.conf.help.variables` (Make variable)
#     2. `BMAKELIB_CONF_HELP_VARIABLES` (environment variable)
#     3. `yes` (default)
#<
####################################################################################################

bmakelib.conf.help.variables ?= $(or $(BMAKELIB_CONF_HELP_VARIABLES),yes)

####################################################################################################
#>
#   # `bmakelib.conf.help.scope`
#
#   Controls which category scopes to display in `bmakelib.help`.
#   Possible values: `all`, `local`, `included`, `builtin` (or a comma-separated combination).
#
#   Precedence:
#     1. `bmakelib.conf.help.scope` (Make variable)
#     2. `BMAKELIB_CONF_HELP_SCOPE` (environment variable)
#     3. `all` (default)
#<
####################################################################################################

bmakelib.conf.help.scope ?= $(or $(BMAKELIB_CONF_HELP_SCOPE),all)

####################################################################################################
#>
#   # `bmakelib.conf.help.tips`
#
#   Controls whether `bmakelib.help` should display the usage notes/tips footer block.
#
#   Precedence:
#     1. `bmakelib.conf.help.tips` (Make variable)
#     2. `BMAKELIB_CONF_HELP_TIPS` (environment variable)
#     3. `yes` (default)
#<
####################################################################################################

bmakelib.conf.help.tips ?= $(or $(BMAKELIB_CONF_HELP_TIPS),yes)
