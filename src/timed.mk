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
#   # `%!bmakelib.timed`
#
#   Times the execution of a given target and report the duration with milliseconds precision.
#   The following variables will be populated:
#     * `stdlib.vars.timed.begin-ts.TARGET_NAME` (nanos)`
#     * `stdlib.vars.timed.end-ts.TARGET_NAME` (nanos)`
#     * `stdlib.vars.timed.duration.TARGET_NAME` (millis)`
#
#   # Example 1
#
#   Makefile:
#
#	```Makefile
#	my-target :
#		@sleep 2
#		@echo my-target is done
#	```
#
#   Shell:
#
#	```
#	$ make my-target!bmakelib.timed
#	Using default value 'yes' for variable 'stdlib.conf.timed.SILENT'
#	my-target is done
#	Target 'my-target' took 2009ms to complete.
#	```
#
#   # Example 2
#
#   Makefile:
#
#	```Makefile
#	some-target :
#		@sleep 2
#
#	my-target : stdlib.conf.timed.SILENT = yes
#	my-target : some-target!bmakelib.timed
#		@echo ✅ Made some-target in $(stdlib.vars.timed.duration.some-target)ms 🙌
#	```
#
#   Shell:
#
#	```
#	$ make my-target
#	✅ Made some-target in 2008ms 🙌
#	```
#<
####################################################################################################

.PHONY : %!bmakelib.timed

%!bmakelib.timed : bmakelib.default-if-blank( bmakelib.conf.timed.SILENT,no ) bmakelib._%!timed
	$(if $(filter yes,$(bmakelib.conf.timed.SILENT)), \
	     , \
	     $(info Target '$(*)' took $(bmakelib.vars.timed.duration.$(*))ms to complete.))

####################################################################################################
#>
#   # `bmakelib.conf.timed.convenience-target`
#
#   Whether to define the convenience target `%!bmakelib.timed`.
#   Set to 'no' *before* including bmakelib to disable.
####################################################################################################

bmakelib.conf.timed.convenience-target ?= yes

####################################################################################################
#>
#   # `%!timed`
#
#   Convenice target with a shorter and more intuitive name.  It's a drop-in replacement for
#   `%!bmakelib.timed`.
#
#   Lets you write
#
#	```Makefile
#	some-target : other-target!timed
#	```
#
#   or
#
#	```
#	$ make my-target!timed
#	```
#
#   See also `bmakelib.conf.timed.convenience-target`.
#<
####################################################################################################

ifneq ($(bmakelib.conf.timed.convenience-target),no)

.PHONY : %!timed

%!timed : %!bmakelib.timed ;

endif

####################################################################################################
#>
#    # `bmakelib.conf.timed.SILENT`
#
#    If set to yes, causes `%!bmakelib.timed` to emit an info containing the duration of the target.
#<
####################################################################################################

bmakelib.conf.timed.SILENT ?= no

####################################################################################################
#   Steps to take before executing the given target
####################################################################################################

.PHONY : bmakelib._%!timed-pre
.NOTINTERMEDIATE : bmakelib._%!timed-pre

bmakelib._%!timed-pre :
	$(eval bmakelib.vars.timed.begin-ts.$(*) := $(shell perl -MTime::HiRes=time -E 'printf("%.0f\n", int(time() * 1e9))'))

####################################################################################################
#   Steps to take after executing the given target
####################################################################################################

.PHONY : bmakelib._%!timed-post
.NOTINTERMEDIATE : bmakelib._%!timed-post

bmakelib._%!timed-post :
	$(eval bmakelib.vars.timed.end-ts.$(*) := $(shell perl -MTime::HiRes=time -E 'printf("%.0f\n", int(time() * 1e9))'))

####################################################################################################
#   Execute the given target and measure the duration
####################################################################################################

.PHONY : bmakelib._%!timed
.NOTINTERMEDIATE : bmakelib._%!timed

bmakelib._%!timed : bmakelib._%!timed-pre .WAIT % .WAIT bmakelib._%!timed-post
	$(eval bmakelib.vars.timed.duration.$(*) := \
		$(shell perl -E 'printf("%.0f", ($(bmakelib.vars.timed.end-ts.$(*)) - $(bmakelib.vars.timed.begin-ts.$(*))) / 1_000_000)'))
