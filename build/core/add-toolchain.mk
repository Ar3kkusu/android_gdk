# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# this script is included repeatedly by main.mk to add a new toolchain
# definition to the GDK build system.
#
# '_config_mk' must be defined as the path of a toolchain
# configuration file (config.mk) that will be included here.
#
$(call assert-defined, _config_mk)

# The list of variables that must or may be defined
# by the toolchain configuration file
#
GDK_TOOLCHAIN_VARS_REQUIRED := TOOLCHAIN_ABIS
GDK_TOOLCHAIN_VARS_OPTIONAL :=

# Clear variables that are supposed to be defined by the config file
$(call clear-vars,$(GDK_TOOLCHAIN_VARS_REQUIRED))
$(call clear-vars,$(GDK_TOOLCHAIN_VARS_OPTIONAL))

# Include the config file
include $(_config_mk)

# Check that the proper variables were defined
$(call check-required-vars,$(GDK_TOOLCHAIN_VARS_REQUIRED),$(_config_mk))

# Check that the file didn't do something stupid
$(call assert-defined, _config_mk)

# Now record the toolchain-specific information
_dir  := $(patsubst %/,%,$(dir $(_config_mk)))
_name := $(notdir $(_dir))
_abis := $(TOOLCHAIN_ABIS)

_toolchain := GDK_TOOLCHAIN.$(_name)

# check that the toolchain name is unique
$(if $(strip $($(_toolchain).defined)),\
  $(call __gdk_error,Toolchain $(_name) defined in $(_parent) is\
                     already defined in $(GDK_TOOLCHAIN.$(_name).defined)))

$(_toolchain).defined := $(_toolchain_config)
$(_toolchain).abis    := $(_abis)
$(_toolchain).setup   := $(wildcard $(_dir)/setup.mk)

$(if $(strip $($(_toolchain).setup)),,\
  $(call __gdk_error, Toolchain $(_name) lacks a setup.mk in $(_dir)))

GDK_ALL_TOOLCHAINS += $(_name)
GDK_ALL_ABIS       += $(_abis)

# NKD_ABI.<abi>.toolchains records the list of toolchains that support
# a given ABI
#
$(foreach _abi,$(_abis),\
    $(eval GDK_ABI.$(_abi).toolchains += $(_name)) \
)

# done
