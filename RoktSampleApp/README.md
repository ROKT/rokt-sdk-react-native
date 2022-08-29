
# React Native 
Install ReactNative by running `npm install -g expo-cli`. The full description could be find here https://reactnative.dev/docs/environment-setup


| Environment | Build |
| ----------- | :----- |
| release |  [![CircleCI](https://circleci.com/bb/ROKT/rokt-sdk-ios/tree/master.svg?style=svg&circle-token=519d542734b554bf3484517306ccecddd243e78c)]

## NPM install on Sample app
go to *RoktSampleApp* directory and run `npm install`

## Start with npx
go to *RoktSampleApp* directory and run `npx react-native start --reset-cache`


# iOS

## Install the pod
go to *RoktSampleApp/iOS* directory and run `pod install` (if pod install failed, rund `pod update` to get the latest libraries)

## run iOS
go to *RoktSampleApp* directory and run `npx react-native run-ios` 

# Android

## run Android
go to *RoktSampleApp* directory and run `npx react-native run-android` 

## CI/CD System

The CI system used is  **CircleCi**  [https://app.circleci.com/pipelines/github/ROKT/rokt-sdk-react-native](https://app.circleci.com/pipelines/github/ROKT/rokt-sdk-react-native)  CircleCi workflows are defined in the  `.circleci`  directory. The iOS step build the app and run the UI test in the CircleCi environment whereas Android step builds the apk in the circleCi environment whereas the UI test is executed in device farm using the fastlane lane ```deviceFarmUITest``` defined in the directory ```RoktSampleApp/android```


# Copyright
Copyright 2020 Rokt Pte Ltd Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); You may not use this file except in compliance with the License. You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
