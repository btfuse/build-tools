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

# Cleanly builds an iOS module and publishes a new version

# Usage:
#
# MODULE_MARKET_NAME="Human Friendly Name"
# MODULE_NAME="moduleName"
# MODULE_DESCRIPTION="The best module ever"
# MODULE_REPO_NAME="my-module"
# MODULE_VERSION="1.2.3"
#
# source build-tools/buildAndroidModule.sh
#
# MODULE_MARKET_NAME is simply used for some prints
# MODULE_NAME should be the name of the android module that needs to be built.
# MODULE_NAME does not support sub-modules. The module should be available
# at the root of the android project.
# MODULE_DESCRIPTION is the description used for pod specs.
# MODULE_REPO_NAME is the repository inside btfuse organization.
# MODULE_VERSION is the new version/tag

# It's assumed that:
#   - the ios workspace is located at in ./ios/
#   - it contains a VERSION file
#   - it contains a BUILD file
#   - That the workspace name and scheme have a consistent name
#   - That the repo has a LICENSE file

source build-tools/assertions.sh
source build-tools/DirectoryTools.sh
source build-tools/tests.sh

assertMac "Mac is required for publishing"
assertGitRepo
assertCleanRepo

if [ -z "$BTFUSE_CODESIGN_IDENTITY" ]; then
    echo "BTFUSE_CODESIGN_IDENTITY environment variable is required."
    exit 2
fi

VERSION="$MODULE_VERSION"

assertVersion $VERSION
assertGitTagAvailable "ios/$VERSION"

echo $VERSION > ios/VERSION
BUILD_NO=$(< "./ios/BUILD")
BUILD_NO=$((BUILD_NO + 1))
echo $BUILD_NO > ./ios/BUILD

./buildIOS.sh
testIOS "Fuse iOS 17" "17.5" "iPhone 15" "$MODULE_NAME" "$MODULE_NAME"

git add ios/VERSION ios/BUILD
git commit -m "iOS Release: $VERSION"
git push
git tag -a ios/$VERSION -m "iOS Release: $VERSION"
git push --tags

gh release create ios/$VERSION \
    ./dist/ios/$MODULE_NAME.xcframework.zip \
    ./dist/ios/$MODULE_NAME.xcframework.zip.sha1.txt \
    ./dist/ios/$MODULE_NAME.framework.dSYM.zip \
    ./dist/ios/$MODULE_NAME.framework.dSYM.zip.sha1.txt \
    --verify-tag --generate-notes

pod spec lint $MODULE_NAME.podspec
assertLastCall

pod repo push breautek $MODULE_NAME.podspec
