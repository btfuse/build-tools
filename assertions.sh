# Copyright 2023 Norman Breau 

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##############
# Asserts the runtime for mac / darwin runtime.
# Kills the bash program otherwise.
#
# Usage: assertMac <reason>
# 
##############
function assertMac {
    local reason="$1"
    if [ `uname` != "Darwin" ]; then
        echo $reason
        exit 1
    fi
}

##############
# Asserts that the current path is inside a Git repo.
# Kills the bash program otherwise.
#
# Usage: assertGitRepo
# 
##############
function assertGitRepo {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Not in a Git repository."
        exit 1
    fi
}

##############
# Asserts that the Git repo is clean.
# Kills the bash program otherwise.
#
# Usage: assertCleanRepo
# 
##############
function assertCleanRepo {
    if ! git diff-index --quiet HEAD --; then
        echo "Git repository is not clean. There are uncommitted changes."
        exit 1
    fi
}

##############
# Asserts that the Git tag is not already used.
# Kills the bash program otherwise.
#
# Usage: assetGitTagAvailable <tag>
# 
##############
function assetGitTagAvailable {
    local tag="$1"
    if git tag -l | grep -q "^$$tag$"; then
        echo "Tag $tag already exists."
        exit 1
    fi
}

##############
# Asserts that version input is not empty.
# Kills the bash program otherwise.
#
# Usage: assertVersion <version>
# 
##############
function assertVersion {
    if [ -z "$1" ]; then
    echo "Version is required."
    exit 2
fi
}

##############
# Asserts that the previous call returned a 0 exit code.
# Kills the bash program otherwise.
#
# Usage:
# someCommand
# assertLastCall
# 
##############
function assertLastCall {
    local exitCode=$?
    if [ $exitCode -ne 0 ]; then
        if [ "$1" != "" ]; then
            echo "$1"
        fi
        exit $exitCode
    fi
}
