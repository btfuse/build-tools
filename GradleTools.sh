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
# Syncs a gradle project to a specific wrapper version.
# Will use /GRADLE_VERSION file if a version is not specified
#
# Usage: syncGradle <projectPath> [gradleVersion]
# 
##############
function syncGradle() {
    local dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source $dir/DirectoryTools.sh

    local gradleProject="$1"
    local gradleVersion=$(echo -n $2)

    if [ "$gradleVersion" == "" ]; then
        gradleVersion=$(echo $(cat GRADLE_VERSION))
    fi

    echo "Syncing Gradle to $gradleVersion"

    echo -n $gradleVersion > GRADLE_VERSION

    spushd $gradleProject
    if [ -e gradlew ]; then
        ./gradlew wrapper --gradle-version $gradleVersion
    else
        gradle wrapper --gradle-version $gradleVersion
    fi
    spopd
}
