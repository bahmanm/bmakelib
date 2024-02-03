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
#   # `bmakelib.shell.error-if-nonzero`
#
#   Executes the given shell command and expands the output.  If the command fails with any non-zero
#   code, fails the Make process with an "error" message.
#
#   ###  Example 1
#
#   Makefile:
#
#	```Makefile
#	VAR1 := $(call bmakelib.shell.error-if-nonzero, echo Kaboom! 💣 && false)
#
#	some-target : VAR2 := $(call bmakelib.shell.error-if-nonzero, echo Hello, world)
#	some-target :
#		@echo Unreachable recipe ⛔
#	```
#
#   Shell:
#
#	```text
#	$ make some-target
#	Makefile:4: *** bmakelib.shell.error-if-nonzero: Command exited with non-zero value 1.  Stop.
#	```
#
#   ###  Example 2
#
#   Makefile:
#
#	```Makefile
#	VAR1 := $(call bmakelib.shell.error-if-nonzero,\
#		       echo 🧑 $$$$(whoami) 💻 $$$$(perl -nE'say $$$$1 if /^ID="(.+)"$$$$/' < /etc/os-release))
#
#	some-target : VAR2 := $(call bmakelib.shell.error-if-nonzero,emacs --version | head -n 1)
#	some-target :
#		@echo VAR1=$(VAR1)
#		@echo VAR2=$(VAR2)
#	```
#
#   Shell:
#
#	```text
#	$ make some-target
#	👉 VAR1=🧑 bahman 💻 opensuse-tumbleweed
#	👉 VAR2=GNU Emacs 29.1
#	```
#
#   ###  Example 3
#
#   Makefile:
#
#	```Makefile
#	VAR1 := $(call bmakelib.shell.error-if-nonzero,\
#	               docker run --rm ubuntu:22.04 echo Hello, world. && echo Goodbye, world.)
#
#	some-target : VAR2 := $(call bmakelib.shell.error-if-nonzero,\
#	                             [[ ! -z $$$$JAVA_HOME ]] \
#				     && ls $$$$JAVA_HOME/bin/java \
#				     || echo JAVA_HOME not set.)
#	some-target :
#		@echo 👉 VAR1=$(VAR1)
#		@echo 👉 VAR2=$(VAR2)
#	```
#
#   Shell:
#
#	```text
#	$ make some-target
#	👉 VAR1=Hello, world. Goodbye, world.
#	👉 VAR2=/home/bahman/.sdkman/candidates/java/current/bin/java
#	```
#
#   ### Notes:
#
#   * Set `bmakelib.conf.shell.error-if-nonzero.SILENT` to "no" to emit an `info` message before
#    running the command.
#
#   * Quad-quote all the variables and structures that are supposed to be only understood by shell.
#     For example:
#     - `$(call bmakelib.shell.error-if-nonzero,echo $$$$HOSTNAME)`
#     - `$(call bmakelib.shell.error-if-nonzero,PATH="/usr/local/foo/bin:$$$$PATH" foo $$$$(date))`
#
#   * Currently the a command can contain upto **9** comma (,) charaters.
#     - This number is totally arbitrary and it can be increased if there's need for it.
#     - Since `$(call)` treats "," (comma) as the parameter separator, it swallows all commas in the
#       commands you pass to `bmakelib.shell.error-if-nonzero`.  This means that those commans need
#       to be manually inserted in the command string.
#<
####################################################################################################

define bmakelib.shell.error-if-nonzero
$(eval bmakelib.shell.error-if-nonzero.__command := $(if $(1),$(1)$(if $(2),$(bmakelib.comma)$(2)$(if $(3),$(bmakelib.comma)$(3)$(if $(4),$(bmakelib.comma)$(4)$(if $(5),$(bmakelib.comma)$(5)$(if $(6),$(bmakelib.comma)$(6)$(if $(7),$(bmakelib.comma)$(7)$(if $(8),$(bmakelib.comma)$(8)$(if $(9),$(bmakelib.comma)$(9)$(if $(10),$(bmakelib.comma)$(10),),),),),),),),),),))$(⬛)$(if $(filter yes,$(bmakelib.conf.shell.error-if-nonzero.SILENT)),,$(info shell.error-if-nonzero: $(bmakelib.shell.error-if-nonzero.__command)))$(⬛)$(eval bmakelib.shell.error-if-nonzero.__result := $(shell $(bmakelib.shell.error-if-nonzero.__command)))$(⬛)$(if $(filter-out 0,$(.SHELLSTATUS)),$(error shell.error-if-nonzero: Command exited with non-zero value $(.SHELLSTATUS)),$(bmakelib.shell.error-if-nonzero.__result))
endef

####################################################################################################
#>
#   # `bmakelib.conf.shell.error-if-nonzero.SILENT`
#
#   Controls whether `bmakelib.shell.error-if-nonzero` should emit an info message before running
#   the command.
#
#   Default is "yes" which means do NOT emit.  Set to "no" to make it behave otherwise.
#<
####################################################################################################

bmakelib.conf.shell.error-if-nonzero.SILENT ?= yes
