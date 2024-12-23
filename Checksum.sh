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

##############
# Calculates a SHA1 checksum and
# writes to $filename.sha1.txt with the value
#
# Usage: sha1_compute <filePath>
# 
##############
function sha1_compute {
    echo -n "$(shasum -a 1 $1  | cut -d ' ' -f 1)" > $1.sha1.txt
}

##############
# Calculates a SHA256 checksum and
# writes to $filename.sha256.txt with the value
#
# Usage: sha1_compute <filePath>
# 
##############
function sha256_compute {
    echo -n "$(shasum -a 256 $1  | cut -d ' ' -f 1)" > $1.sha256.txt
}
