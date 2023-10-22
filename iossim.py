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

import sys
import subprocess
import json

def main():
    if len(sys.argv) != 4:
        print("Usage: python iossim.py <Sim Name> <Sim Runtime> <Device Type>")
        sys.exit(1)

    devName = sys.argv[1]
    
    runtime = getRuntimeByName(sys.argv[2])

    if runtime == None:
        print("No runtime found by the name of " + sys.argv[2])
        sys.exit(1)

    # First check to make sure the simulator doesn't already exists
    deviceUDID = getSimByName(devName, runtime)
    if deviceUDID != None:
        # Already has device
        print(deviceUDID)
        sys.exit(0)

    # Otherwise create it
    device = getDeviceTypeByName(sys.argv[3])

    deviceUDID = createSim(devName, device, runtime)
    if deviceUDID == None:
        print("Could not create simulator with for " + device + "/" + runtime)
        sys.exit(1)

    print(deviceUDID)
    sys.exit(0)

def createSim(name, device, runtime):
    try:
        subprocess.run([
            "xcrun", "simctl", "create", name, device, runtime
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
    except subprocess.CalledProcessError as ex:
        print("xcrun failed with error:", ex)
        raise ex
    
    return getSimByName(name, runtime)

def getDeviceTypeByName(name):
    result = None
    try:
        result = subprocess.run([
            "xcrun", "simctl", "list", "devicetypes", "--json"
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
    except subprocess.CalledProcessError as ex:
        print("xcrun failed with error:", ex)
        raise ex
    
    types = None
    if result.stdout:
        try:
            types = json.loads(result.stdout)["devicetypes"]
            # runtimes = runtimes
        except json.JSONDecodeError as ex:
            print("JSON Error JSON:", ex)
            raise ex

    for dt in types:
        if name == dt["name"]:
            return dt["identifier"]
    
    return None

def getRuntimeByName(name):
    result = None
    try:
        result = subprocess.run([
            "xcrun", "simctl", "list", "runtimes", "--json"
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
    except subprocess.CalledProcessError as ex:
        print("xcrun failed with error:", ex)
        raise ex
    
    runtimes = None
    if result.stdout:
        try:
            runtimes = json.loads(result.stdout)["runtimes"]
            # runtimes = runtimes
        except json.JSONDecodeError as ex:
            print("JSON Error JSON:", ex)
            raise ex

    for runtime in runtimes:
        if name == runtime["name"]:
            return runtime["identifier"]
    
    return None

def getSimByName(name, runtime):
    result = None
    try:
        result = subprocess.run([
            "xcrun", "simctl", "list", "devices", "--json"
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
    except subprocess.CalledProcessError as ex:
        print("xcrun failed with error:", ex)
        raise ex
    
    devices = None
    if result.stdout:
        try:
            devices = json.loads(result.stdout)["devices"][runtime]
        except json.JSONDecodeError as ex:
            print("JSON Error JSON:", ex)
            raise ex
    
    for device in devices:
        if name == device["name"]:
            return device["udid"]
    
    return None

if __name__ == "__main__":
    main()
