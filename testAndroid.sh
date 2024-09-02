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

source build-tools/assertions.sh
source build-tools/DirectoryTools.sh

source build-tools/Env.sh

target="$1"

spushd android
    echo "TARGET: $target"
    if [ "$target" == "" ]; then
        # There's a bug that prevents concurrent tests to run via GMD
        # ./gradlew \
        #     --parallel test \
        #     --parallel api27DebugAndroidTest \
        #     --parallel api28DebugAndroidTest \
        #     --parallel api29DebugAndroidTest 
        #     # --parallel api30DebugAndroidTest \
        #     # --parallel api31DebugAndroidTest \
        #     # --parallel api32DebugAndroidTest \
        #     # --parallel api33DebugAndroidTest \
        #     # --parallel api34DebugAndroidTest
        # assertLastCall

        ./gradlew test
        assertLastCall

        ./gradlew api27DebugAndroidTest
        assertLastCall
        ./gradlew api28DebugAndroidTest
        assertLastCall
        ./gradlew api29DebugAndroidTest
        assertLastCall
        ./gradlew api30DebugAndroidTest
        assertLastCall
        ./gradlew api31DebugAndroidTest
        assertLastCall
        ./gradlew api32DebugAndroidTest
        assertLastCall
        ./gradlew api33DebugAndroidTest
        assertLastCall
        ./gradlew api34DebugAndroidTest
        assertLastCall
    elif [ "$target" == "local" ]; then
        ./gradlew test
        assertLastCall
    elif [ "$target" == "device" ]; then
        ./gradlew cAT
        assertLastCall
    else
        ./gradlew api${target}DebugAndroidTest
        assertLastCall
    fi
spopd
