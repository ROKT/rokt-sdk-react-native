#!/bin/bash

set -eu

# $1 version

git checkout -b "v$1"
git add ../Rokt.Widget/android/build.gradle
git add ../Rokt.Widget/rokt-react-native-sdk.podspec
git commit -m "v$1"
git tag -a v$1 -m "Automated release v$1"
git push origin v$1