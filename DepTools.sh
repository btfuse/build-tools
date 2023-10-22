
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

source build-tools/DirectoryTools.sh
source build-tools/assertions.sh

function SyncModules {
    git submodule update --recursive --init
    git submodule update --recursive
}

# Usage:
# SyncDepFromGitHub <repo-owner> <repo-name> <version> <filename>
function SyncDepFromGitHub {
    local depOwner="$1"
    local depPackage="$2"
    local depVersion="$3"
    local depFile="$4"

    local shouldDownload="0"

    EXPECTED_CHECK=$(gh release download -R $depOwner/$depPackage $depVersion -p $depFile.sha1.txt -O -)
    assertLastCall

    if [ -s "deps/.$depFile" ]; then
        CURRENT_CHECK="$(cat deps/.$depFile)"
        assertLastCall
        if [ "$CURRENT_CHECK" != "$EXPECTED_CHECK" ]; then
            shouldDownload="1"
        fi
    else
        shouldDownload="1"
    fi

    if [ "$shouldDownload" == "0" ]; then
        echo "Skipping $depPackage... already up to date"
        return
    fi

    echo "Syncing $depPackage..."

    local depFolder="deps/$depPackage/${depPackage}_${depFile}"

    rm -rf "$depFolder"
    rm -f "deps/.$depFile"

    mkdir -p $depFolder

    echo "Downloading $depFile..."
    gh release download -R $depOwner/$depPackage $depVersion -p $depFile -O $depFolder/$depFile
    assertLastCall

    if [[ $depFile == *.zip ]]; then
        spushd $depFolder
            unzip $depFile
            assertLastCall
            rm -f $depFile
        spopd
    fi

    echo -n $EXPECTED_CHECK > deps/.$depFile
}
