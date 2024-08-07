
#!/bin/bash

# Copyright 2024 Breautek 

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Loads the environment
# The environment must have a vars.sh file which declares the following variables:
# - MODULE_NAME
# - MODULE_MARKET_NAME
# - MODULE_DESCRIPTION
# - MODULE_REPO_NAME

# MODULE_MARKET_NAME is simply used for some prints
# MODULE_NAME should be the name of the android module that needs to be built.
# MODULE_NAME does not support sub-modules. The module should be available
# at the root of the android project.
# MODULE_DESCRIPTION is the description used for pod specs.
# MODULE_REPO_NAME is the repository inside btfuse organization.

source build-tools/assertions.sh

if [ ! -f "vars.sh" ]; then
    echo "vars.sh does not exist or is not a file."
    exit 1
fi

source vars.sh

if [ -z "$MODULE_NAME" ]; then
    echo "MODULE_NAME variable is required."
    exit 2
fi

if [ -z "$MODULE_MARKET_NAME" ]; then
    echo "MODULE_MARKET_NAME variable is required."
    exit 2
fi

if [ -z "$MODULE_DESCRIPTION" ]; then
    echo "MODULE_DESCRIPTION variable is required."
    exit 2
fi

if [ -z "$MODULE_REPO_NAME" ]; then
    echo "MODULE_REPO_NAME variable is required."
    exit 2
fi
