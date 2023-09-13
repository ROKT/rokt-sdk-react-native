#!/bin/bash

set -eu

# $1 version

WIDGET_DIR="$(dirname $0)/../../Rokt.Widget"

cd $WIDGET_DIR

git config user.email "buildkite@rokt.com"
git config user.name "Buildkite"

git tag -d "v$1" || true
git add ./android/build.gradle
git add rokt-react-native-sdk.podspec
git add package.json
git commit -m "v$1"
git tag -a "v$1" -m "Automated release v$1"
git push origin "v$1"