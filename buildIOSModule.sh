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

# Builds an iOS module and places it in
# dist/ios/

# Usage:
#
# MODULE_MARKET_NAME="Human Friendly Name"
# MODULE_NAME="moduleName"
# MODULE_DESCRIPTION="The best module ever"
# MODULE_REPO_NAME="my-module"
#
# source build-tools/buildAndroidModule.sh
#
# MODULE_MARKET_NAME is simply used for some prints
# MODULE_NAME should be the name of the android module that needs to be built.
# MODULE_NAME does not support sub-modules. The module should be available
# at the root of the android project.
# MODULE_DESCRIPTION is the description used for pod specs.
# MODULE_REPO_NAME is the repository inside btfuse organization.

# It's assumed that:
#   - the ios workspace is located at in ./ios/
#   - it contains a VERSION file
#   - it contains a BUILD file
#   - That the workspace name and scheme have a consistent name

source build-tools/assertions.sh
source build-tools/DirectoryTools.sh
source build-tools/Checksum.sh

if [ -z "$BTFUSE_CODESIGN_IDENTITY" ]; then
    echo "BTFUSE_CODESIGN_IDENTITY environment variable is required."
    exit 2
fi

if [ -z "$MODULE_NAME" ]; then
    echo "MODULE_NAME variable is required."
    exit 2
fi

if [ -z "$MODULE_MARKET_NAME" ]; then
    echo "MODULE_MARKET_NAME variable is required."
    exit 2
fi

assertMac "Mac is required to build Fuse $MODULE_MARKET_NAME iOS"

VERSION=$(< "./ios/VERSION")

echo "Building Fuse $MODULE_MARKET_NAME iOS Framework $VERSION..."

rm -rf ./dist/ios
mkdir -p ./dist/ios

echo "Cleaning the workspace..."
spushd ios
    BUILD_NO=$(< BUILD)
    echo "// This is an auto-generated file, do not edit!" > $MODULE_NAME/VERSION.xcconfig
    echo "CURRENT_PROJECT_VERSION = $BUILD_NO" >> $MODULE_NAME/VERSION.xcconfig
    echo "MARKETING_VERSION = $VERSION" >> $MODULE_NAME/VERSION.xcconfig

    xcodebuild -quiet -workspace $MODULE_NAME.xcworkspace -scheme $MODULE_NAME -configuration Release -destination "generic/platform=iOS" clean
    assertLastCall
    xcodebuild -quiet -workspace $MODULE_NAME.xcworkspace -scheme $MODULE_NAME -configuration Debug -destination "generic/platform=iOS Simulator" clean
    assertLastCall

    echo "Building iOS framework..."
    xcodebuild -quiet -workspace $MODULE_NAME.xcworkspace -scheme $MODULE_NAME -configuration Release -destination "generic/platform=iOS" build
    assertLastCall
    echo "Building iOS Simulator framework..."
    xcodebuild -quiet -workspace $MODULE_NAME.xcworkspace -scheme $MODULE_NAME -configuration Debug -destination "generic/platform=iOS Simulator" build
    assertLastCall

    iosBuild=$(echo "$(xcodebuild -workspace $MODULE_NAME.xcworkspace -scheme $MODULE_NAME -configuration Release -sdk iphoneos -showBuildSettings | grep -E '^\s*CONFIGURATION_BUILD_DIR =' | awk -F '= ' '{print $2}' | xargs)")
    simBuild=$(echo "$(xcodebuild -workspace $MODULE_NAME.xcworkspace -scheme $MODULE_NAME -configuration Debug -sdk iphonesimulator -showBuildSettings | grep -E '^\s*CONFIGURATION_BUILD_DIR =' | awk -F '= ' '{print $2}' | xargs)")

    echo "Signing iOS build..."
    codesign -s $BTFUSE_CODESIGN_IDENTITY "$iosBuild/$MODULE_NAME.framework"

    echo "Verifying iOS Build"
    codesign -dvvvv "$iosBuild/$MODULE_NAME.framework"
    assertLastCall

    cp -r $iosBuild/$MODULE_NAME.framework.dSYM ../dist/ios/

    xcodebuild -create-xcframework \
        -framework $iosBuild/$MODULE_NAME.framework \
        -debug-symbols $iosBuild/$MODULE_NAME.framework.dSYM \
        -framework $simBuild/$MODULE_NAME.framework \
        -output ../dist/ios/$MODULE_NAME.xcframework
    assertLastCall
spopd

spushd dist/ios
    zip -r $MODULE_NAME.xcframework.zip $MODULE_NAME.xcframework > /dev/null
    zip -r $MODULE_NAME.framework.dSYM.zip $MODULE_NAME.framework.dSYM > /dev/null
    sha1_compute $MODULE_NAME.xcframework.zip
    sha1_compute $MODULE_NAME.framework.dSYM.zip
spopd

CHECKSUM=$(cat ./dist/ios/$MODULE_NAME.xcframework.zip.sha1.txt)

podspec=$(<$MODULE_NAME.podspec.template)
podspec=${podspec//\$VERSION\$/$VERSION}
podspec=${podspec//\$CHECKSUM\$/$CHECKSUM}
podspec=${podspec//\$MODULE_NAME\$/$MODULE_NAME}
podspec=${podspec//\$MODULE_REPO_NAME\$/$MODULE_REPO_NAME}
podspec=${podspec//\$MODULE_DESCRIPTION\$/$MODULE_DESCRIPTION}

echo "$podspec" > $MODULE_NAME.podspec
