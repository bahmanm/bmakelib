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
#   # `!!bmakelib.logged`
#
#   Logs the output of a given target to file.
#
#   ### Example 1
#
#   Makefile:
#
#	```Makefile
#	some-target :
#		@echo ✅ some-target is done!
#	```
#
#   Shell:
#
#	```text
#	$ make my-target!!bmakelib.logged
#	Logging target some-target to some-target-20230808-16221691536940-884103049.logged
#	exec 3>&1 4>&2 \
#	&& trap 'exec 2>&4 1>&3' 0 1 2 3 \
#	&& exec 1>/tmp/tmp.37mr7DpGnn/test_logged/some-target-20230808-16221691536940-884103049.logged 2>&1 \
#	&& make -f Makefile some-target
#
#	$ cat some-target-20230808-16221691536940-884103049.logged
#	✅ some-target is done!
#	```
#
#   ### Example 2
#
#   Makefile:
#
#	```Makefile
#	some-target :
#		@echo 🤖 Done this and that.
#	```
#
#   Shell:
#
#	```text
#	$ make bmakelib.conf.logged.SILENT=yes \
#	       bmakelib.conf.logged.ECHO_COMMAND=no \
#	       some-target!!bmakelib.logged
#
#	$ cat some-target-20230808-16221691536940-834199518.logged
#	🤖 Done this and that.
#	```
#
#   ### Notes
#
#     * See `!!logged` below for a shorter name.
#     * The name contains two consecutive exclamation marks (`!!`).  That is to denote that it runs a
#       a new make process.
#     * The log file name format is `TARGET_NAME-<time-format>.<microseconds>.logged`.
#     * See `bmakelib.conf.logged.output-dir` to customise the output directory for logs.
#     * See `bmakelib.conf.logged.time-format` to customise the timestamp format.
#<
####################################################################################################

%!!bmakelib.logged :
	$(call bmakelib.logged._make-and-log-target,$(*))

####################################################################################################
#>
#   # `bmakelib.conf.logged.output-dir`
#
#   The directory where log files are written.
#
#   Precedence for resolving the output directory:
#     1. `bmakelib.conf.logged.output-dir` (Make variable)
#     2. `BMAKELIB_CONF_LOGGED_OUTPUT_DIR` (environment variable)
#     3. `ROOT` (legacy Make or environment variable)
#     4. `./` (default)
#<
####################################################################################################

bmakelib.conf.logged.output-dir ?= $(or $(BMAKELIB_CONF_LOGGED_OUTPUT_DIR),$(ROOT),./)

####################################################################################################
#>
#   # `bmakelib.conf.logged.convenience-target`
#
#   Whether to define the convenience target `%!!logged`.
#   Set to 'no' *before* including bmakelib to disable.
#
#   Precedence:
#     1. `bmakelib.conf.logged.convenience-target` (Make variable)
#     2. `BMAKELIB_CONF_LOGGED_CONVENIENCE_TARGET` (environment variable)
#     3. `yes` (default)
#<
####################################################################################################

bmakelib.conf.logged.convenience-target ?= $(or $(BMAKELIB_CONF_LOGGED_CONVENIENCE_TARGET),yes)

####################################################################################################
#>
#   # `!!logged`
#
#   Convenience target with a shorter and more intuitive name.  It's a drop-in replacement for
#   `!!bmakelib.logged`.
#
#   Lets you write
#
#	```Makefile
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

%!!logged : %!!bmakelib.logged ;

endif

####################################################################################################
#>
#   # `bmakelib.conf.logged.SILENT`
#
#   If set to yes, causes `!!bmakelib.logged` to emit an info containing the log filename.
#
#   Precedence:
#     1. `bmakelib.conf.logged.SILENT` (Make variable)
#     2. `BMAKELIB_CONF_LOGGED_SILENT` (environment variable)
#     3. `no` (default)
#<
####################################################################################################

bmakelib.conf.logged.SILENT ?= $(or $(BMAKELIB_CONF_LOGGED_SILENT),no)

####################################################################################################
#>
#   # `bmakelib.conf.logged.ECHO_COMMAND`
#
#   If set to no, causes `!!bmakelib.logged` to not echo the actual command it runs.
#
#   Precedence:
#     1. `bmakelib.conf.logged.ECHO_COMMAND` (Make variable)
#     2. `BMAKELIB_CONF_LOGGED_ECHO_COMMAND` (environment variable)
#     3. `yes` (default)
#<
####################################################################################################

bmakelib.conf.logged.ECHO_COMMAND ?= $(or $(BMAKELIB_CONF_LOGGED_ECHO_COMMAND),yes)

####################################################################################################
#>
#   # `bmakelib.conf.logged.time-format`
#
#   The `strftime`-compatible format string used for the timestamp in log filenames.
#   Microseconds are always appended to avoid filename collisions.
#
#   Precedence:
#     1. `bmakelib.conf.logged.time-format` (Make variable)
#     2. `BMAKELIB_CONF_LOGGED_TIME_FORMAT` (environment variable)
#     3. `%Y%m%d-%H%M%S` (default)
#<
####################################################################################################

bmakelib.conf.logged.time-format ?= $(or $(BMAKELIB_CONF_LOGGED_TIME_FORMAT),%Y%m%d-%H%M%S)

####################################################################################################
#   $(bmakelib.logged._make-and-log-target TARGET)
#
#   Emits an info message announcing the log filename and expands to the command which actually runs
#   `TARGET`.
####################################################################################################

define bmakelib.logged._make-and-log-target

$(let ts,$(shell perl -MTime::HiRes=time -MPOSIX \
		-E 'my ($$fmt) = @ARGV; $$e = time(); $$m = ($$e - int($$e)) * 1e6;' \
		-E 'print strftime($$fmt, localtime($$e)); printf(".%06.0f", $$m)' \
		-- "$(or $(bmakelib.conf.logged.time-format),%Y%m%d-%H%M%S)"),
	$(let log-dir,$(patsubst %/,%,$(or $(bmakelib.conf.logged.output-dir),.))/,
		$(let log-file,$(log-dir)$(1)-$(ts).logged,
			$(if $(filter yes,$(bmakelib.conf.logged.SILENT)), \
				, \
				$(info Logging target $(1) to $(log-file)))
			$(call bmakelib.logged._logged-shell-command, \
				$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(1),$(log-file)))))

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
