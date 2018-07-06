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

echo "Download APK for F-Droid from Jenkins"
wget https://matrix.org/jenkins/view/MatrixView/job/VectorAndroid/lastSuccessfulBuild/artifact/riotFDroid.apk

echo "Download APK for GooglePlay from Jenkins"
wget https://matrix.org/jenkins/view/MatrixView/job/VectorAndroid/lastSuccessfulBuild/artifact/riotGooglePlay.apk

# Get versionName of APK
# sed could be done in one line; but it is not working
versionName=`~/Library/Android/sdk/build-tools/27.0.3/aapt dump badging riotGooglePlay.apk | grep versionName | sed "s/.*versionName='//" | sed "s/'.*//"`

echo "versionName is $versionName"
echo

targetDir="Riot_$versionName"

echo "Create directory $targetDir/"
mkdir ${targetDir}

echo "Move APK to $targetDir/"
mv *.apk ${targetDir}

echo "Success!"
