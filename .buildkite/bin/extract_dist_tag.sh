#!/bin/bash

set -eu

# Gets the semver label e.g. "1.2.3-alpha.4" gets "alpha"
# If there is not label, print npm default of "latest"

# $1 New React Native SDK version

TAG=$(echo $1 | awk -F'[\.|-]' '{print $4}')

if [ -z "$TAG" ] ;
then
    echo "latest"
else
    echo $TAG
fi