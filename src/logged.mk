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
#   # `%!!bmakelib.logged`
#
#   Log the output of a given target to file.
#
#   # Notes
#
#     * The name contains two consecutive exclamation marks (!!).  That is to denote that it runs a
#       a new make process.
#     * The log file name format is `TARGET_NAME-%Y%m%d-%H%M%s-%N.logged` (a la `date` command.)
#
#   # Example 1
#
#   Makefile:
#
#	```
#	some-target :
#		@echo Running some-target...
#	```
#
#   Shell:
#
#	```
#	$ make my-target!!bmakelib.logged
#	Logging target some-target to some-target-20230808-16221691536940-884103049.logged
#	exec 3>&1 4>&2 \
#	&& trap 'exec 2>&4 1>&3' 0 1 2 3 \
#	&& exec 1>/tmp/tmp.37mr7DpGnn/test_logged/some-target-20230808-16221691536940-884103049.logged 2>&1 \
#	&& make -f Makefile some-target
#	$ cat some-target-20230808-16221691536940-884103049.logged
#	Running some-target...
#	```
#
#   # Example 2
#
#   Makefile:
#
#	```
#	some-target :
#		@echo Running some-target...
#	```
#
#   Shell:
#
#	```
#	$ make bmakelib.conf.logged.SILENT=yes \
#	       bmakelib.conf.logged.ECHO_COMMAND=no \
#	       some-target!!bmakelib.logged
#	$ cat some-target-20230808-16221691536940-834199518.logged
#	Running some-target...
#	```
#<
####################################################################################################

.PHONY : %!!bmakelib.logged

%!!bmakelib.logged : bmakelib.error-if-blank( ROOT )
	$(call bmakelib.logged._make-and-log-target,$(*))

####################################################################################################
#>
#   # `bmakelib.conf.logged.convenience-target`
#
#   Whether to define the convenience target `%!!logged`.
#   Set to 'no' *before* including bmakelib to disable.
#<
####################################################################################################

bmakelib.conf.logged.convenience-target ?= yes

####################################################################################################
#>
#   # `%!!logged`
#
#   Convenience target with a shorter and more intuitive name.  It's a drop-in replacement for
#   `%!!bmakelib.logged`.
#
#   Lets you write
#
#	```
#	some-target : other-target!!logged
#	```
#
#   or
#
#	```
#	$ make my-target!!logged
#	```
#
#   See also `bmakelib.conf.logged.convenience-target`.
#<
####################################################################################################

ifneq ($(bmakelib.conf.logged.convenience-target),no)

.PHONY : %!!logged

%!!logged : %!!bmakelib.logged ;

endif

####################################################################################################
#>
#   # `bmakelib.conf.logged.SILENT`
#
#   If set to yes, causes `%!!bmakelib.logged` to emit an info containing the log filename.
#<
####################################################################################################

bmakelib.conf.logged.SILENT ?= no

####################################################################################################
#>
#   # `bmakelib.conf.logged.ECHO_COMMAND`
#
#   If set to no, causes `%!!bmakelib.logged` to not echo the actual command it runs.
#<
####################################################################################################

bmakelib.conf.logged.ECHO_COMMAND ?= yes

####################################################################################################
#   $(bmakelib.logged._make-and-log-target TARGET)
#
#   Emits an info message announcing the log filename and expands to the command which actually runs
#   `TARGET`.
####################################################################################################

define bmakelib.logged._make-and-log-target

$(let log-file,$(ROOT)$(1)-$(shell date +'%Y%m%d-%H%M%s-%N').logged,
	$(if $(filter yes,$(bmakelib.conf.logged.SILENT)), \
		, \
		$(info Logging target $(1) to $(log-file)))
	$(call bmakelib.logged._logged-shell-command,$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(1),$(log-file)))

endef

####################################################################################################
#   $(bmakelib.logged._logged-shell-command COMMAND,LOGFILE)
#
#   Expands to the sequence of commands that redirect stdout/err to `LOGFILE`, execute `COMMAND` and
#   restore stdout/err once done.
#
#   If `bmakelib.conf.logged.ECHO_COMMAND` is set to no, causes the command to not be echo'ed.
####################################################################################################

define bmakelib.logged._logged-shell-command

$(if $(filter yes,$(bmakelib.conf.logged.ECHO_COMMAND)),,@)exec 3>&1 4>&2 $(bmakelib.backslash)$(bmakelib.newline)\
&& trap 'exec 2>&4 1>&3' 0 1 2 3 $(bmakelib.backslash)$(bmakelib.newline)\
&& exec 1>$(2) 2>&1 $(bmakelib.backslash)$(bmakelib.newline)\
&& $(1)

endef
