
source build-tools/assertions.sh
source build-tools/DirectoryTools.sh

# Usage:
# testIOS <SIM Name> <simVersion> <simModel> <workspace> <scheme>
# 
# Using the same SIM Name will reuse the same simulator if it already exists.
# Sim Version is the iOS version.
# Sim model will be a device model
# Workspace is the filename, without the extension.
# Scheme is the test scheme.
# 
# Example: testIOS "Fuse iOS 17" "17.5" "iPhone 15" "BTFuse" "BTFuseTests"
function testIOS {
    local simName="$1"
    local simVersion="$2"
    local simModel="$3"
    local workspace="$4"
    local scheme="$5"

    SIM=$(python3 ./build-tools/iossim.py "$simName" "iOS $simVersion"  "$simModel")

    xcrun simctl boot $SIM > /dev/null

    spushd ios
        echo "Using Simulator $SIM"
        xcodebuild -quiet test -workspace $workspace.xcworkspace -scheme $scheme -enableCodeCoverage YES -destination-timeout 60 -destination "id=$SIM"
        assertLastCall "Test failed on $SIM"
    spopd

    echo "Test passed on $SIM"
}
