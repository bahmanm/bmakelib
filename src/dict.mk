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
#   # `bmakelib.dict`
#
#   Provides a dictionary (aka map) in your makefiles.
#
#   Among other usecases, a dictionary can be used to group related variables/values together.
#
#   ### Example 1
#
#	```Makefile
#	$(call bmakelib.dict.define,DEPLOY)
#	$(call bmakelib.dict.put,DEPLOY,env,prod)
#	$(call bmakelib.dict.put,DEPLOY,service,the-accounts-service)
#	$(call bmakelib.dict.put,DEPLOY,host,accounts.my-cool-product.com)
#	$(call bmakelib.dict.put,DEPLOY,gpg-key,992443840122)
#
#	$(call bmakelib.dict.define,BUILD)
#	$(call bmakelib.dict.put,BUILD,arch,x86_64)
#	$(call bmakelib.dict.put,BUILD,dir,/tmp/my-app/build)
#
#	some-target :
#		@echo DEPLOY.env = $(call bmakelib.dict.get,DEPLOY,env)
#		@echo BUILD.arch = $(call bmakelib.dict.get,BUILD,arch)
#	```
#
#   ### Example 2
#
#	```Makefile
#	define-config : bmakelib.dict.define( DEPLOY,env,prod )
#	define-config : bmakelib.dict.put( DEPLOY,env,prod )
#	define-config : bmakelib.dict.put( DEPLOY,service,accounts )
#	define-config : bmakelib.dict.put( DEPLOY,host,accounts.my-cool-product.com )
#	define-config : bmakelib.dict.put( DEPLOY,gpg-key,992443840122 )
#
#	deploy : define-config
#	deploy :
#		/usr/bin/deploy \
#			--env $(call bmakelib.dict.get,DEPLOY,env) \
#			--server $(call bmakelib.dict.get,DEPLOY,service) \
#			$(call bmakelib.dict.get,DEPLOY,host)
#	```
#<
####################################################################################################

####################################################################################################
#>
#   # `bmakelib.dict.define`
#
#   Defines a dictionary.
#
#   ### Example 1
#
#	```Makefile
#	$(call bmakelib.dict.define,MY-DICT)
#	```
#
#   The above snippet defines a dictionary named `MY-DICT` which can later be used to
#   store/retrieve items into/from.
#
#   ### Example 2
#
#   Makefile:
#
#	```Makefile
#	my-config-target : bmakelib.dict.define( MY-DICT )
#
#	```
#
#   The above snippet creates a target which has a dependency on `bmakelib.dict.define`, causing
#   it to define dictionary `MY-DICT` when it is invoked.
#<
####################################################################################################

define bmakelib.dict.define
$(eval bmakelib.dict.define.__$(1) := 1)
endef

####################################################################################################

.PHONY : bmakelib.dict.define

bmakelib.dict.define(%) :
	$(eval $$(call bmakelib.dict.define,$(*)))

####################################################################################################
#>
#   # `bmakelib.dict.put`
#
#   Stores a given value in the dictionary under a given key.
#
#   ### Example 1
#
#	```Makefile
#	$(call bmakelib.dict.define,MY-DICT)
#	$(call bmakelib.dict.put,MY-DICT,a-key,a-value)
#	```
#
#   The above, stores the value `a-value` with the key `a-key` in `MY-DICT` dictionary.
#
#   ### Example 2
#
#	```Makefile
#	my-config-target : bmakelib.dict.define( MY-DICT )
#	my-config-target : bmakelib.dict.put( MY-DICT,a-key,a-value )
#
#	```
#
#   The above snippet creates a target which has a dependency on `bmakelib.dict.put(%)`, causing
#   it to store the value `a-value` with key `a-key` in the `MY-DICT` when invoked.
#<
####################################################################################################

define bmakelib.dict.put
$(eval bmakelib.dict.define.__$(1).$(2) := $(3))
endef

####################################################################################################

.PHONY : bmakelib.dict.put

bmakelib.dict.put(%) :
	$(eval $$(call bmakelib.dict.put,$(*)))

####################################################################################################
#>
#   # `bmakelib.dict.get`
#
#   Retrieves the value of a given key from the dictionary.
#
#   ### Example 1
#
#	```Makefile
#	VAR1 = $(call bmakelib.dict.get,MY-DICT,a-key)
#	```
#
#   The above, stores the value `a-value` with the key `a-key` in `MY-DICT` dictionary.
#
#   ### Example 2
#
#	```Makefile
#	some-target :
#		echo $(call bmakelib.dict.get,MY-DICT,a-key)
#	```
#
#   The above snippet creates a target which has a dependency on `bmakelib.dict.put(%)`, causing
#   it to store the value `a-value` with key `a-key` in the `MY-DICT` when invoked.
#<
####################################################################################################

define bmakelib.dict.get
$(bmakelib.dict.define.__$(1).$(2))
endef
