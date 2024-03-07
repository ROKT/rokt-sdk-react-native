#!/bin/bash

set -eu

# $1 New React Native SDK version

cd RoktSampleApp
perl -pi -e "s/(?<=rokt-react-native-sdk-)(.*)(?=\.tgz)/$1/g" package.json
npm i
cd ios
bundle check || bundle install --path vendor/bundle 
bundle exec pod update rokt-react-native-sdk