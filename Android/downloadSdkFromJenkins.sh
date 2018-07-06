#!/usr/bin/env bash

#
# Copyright 2018 New Vector Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Exit on any error
set -e

echo "Which AAR version do you want to download (ex: '0.9.5')?"

read aarVersion

echo "Download $aarVersion aar from Jenkins"
wget https://matrix.org/jenkins/view/MatrixView/job/MatrixAndroidSDK/lastSuccessfulBuild/artifact/matrix-sdk/build/outputs/aar/matrix-sdk-release-${aarVersion}.aar

echo "Copy downloaded AAR to the Riot project"
cp matrix-sdk-release-${aarVersion}.aar ~/workspaces/riot-android/vector/libs/matrix-sdk.aar

targetDir="SDK_$aarVersion"

echo "Create directory $targetDir/"
mkdir ${targetDir}

echo "Move AAR to $targetDir/"
mv *.aar ${targetDir}

echo "Success!"
