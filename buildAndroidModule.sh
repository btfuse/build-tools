
#!/bin/bash

# Copyright 2023 Breautek 

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Builds an Android module and places it in
# dist/android/

# Usage:
#
# MODULE_MARKET_NAME="Human Friendly Name"
# MODULE_NAME="moduleName"
# MODULE_DIR="plugins/module"
#
# source build-tools/buildAndroidModule.sh
#
# MODULE_MARKET_NAME is simply used for some prints
# MODULE_NAME should be the name of the android module that needs to be built.
# MODULE_NAME does not support sub-modules. The module should be available
# at the root of the android project.

# It's assumed that:
#   - the android project is located at ./android
#   - it contains a VERSION file
#   - It has a gradle wrapper installed.

echo "Deprecated"

source build-tools/assertions.sh
source build-tools/DirectoryTools.sh
source build-tools/Checksum.sh

if [ -z "$MODULE_NAME" ]; then
    echo "MODULE_NAME variable is required."
    exit 2
fi

if [ -z "$MODULE_MARKET_NAME" ]; then
    echo "MODULE_MARKET_NAME variable is required."
    exit 2
fi

spushd $MODULE_DIR
    VERSION=$(< "./android/VERSION")

    echo "Building Fuse $MODULE_MARKET_NAME Android Framework $VERSION..."

    rm -rf ./dist/android
    mkdir -p ./dist/android

    echo "Cleaning the workspace..."
    spushd $ANDROID_PROJECT_DIR
        $GRADLE :plugins:$MODULE_NAME:clean
        assertLastCall
        $GRADLE :plugins:$MODULE_NAME:build
        assertLastCall
    spopd

    rm -rf dist/android
    mkdir -p dist/android

    cp android/$MODULE_NAME/build/outputs/aar/*.aar dist/android/
    assertLastCall

    spushd dist/android
        mv $MODULE_NAME-debug.aar $MODULE_NAME-$VERSION-debug.aar
        mv $MODULE_NAME-release.aar $MODULE_NAME-$VERSION.aar
        sha1_compute $MODULE_NAME-$VERSION-debug.aar
        sha1_compute $MODULE_NAME-$VERSION.aar
    spopd
spopd
