


# React Native 

## Resident Experts

- Danial Motahari - danial.motahari@rokt.com
- Sahil Suri - sahil.suri@rokt.com

## Overview
The RoktSampleApp includes bare-minimum UI to demonstrate the usage of React Native SDK for our partners and testing
The application includes the common functionality in the ```*.js files``` whereas the platform specific code is written in the respective platform package example ```android or ios```.
We use ```npm``` package manager to manage the dependencies for the project.


| Environment | Build |
| ----------- | :----- |
| release |  [![Build status](https://badge.buildkite.com/e75677bd3c8e83f1da750aa9124df1f418f211c9c630765ffd.svg)](https://buildkite.com/rokt/react-native-sdk)

## CI/CD System

The CI system used is  **Buildkite**  [https://buildkite.com/rokt/react-native-sdk/](https://buildkite.com/rokt/react-native-sdk/) Buildkite workflows are defined in the  `.buildkite`  directory. The iOS step build the app and run the UI test in the Buildkite environment whereas Android step builds the apk in the Buildkite environment whereas the UI test is executed in device farm using the fastlane lane ```deviceFarmUITest``` defined in the directory ```RoktSampleApp/android```

## Local Setup

### NPM install on Sample app
1. Go to *RoktSampleApp* directory
2. `npm install`
3. If installation errors on Rokt.Widget/rokt-react-native-sdk-X.X.X.tgz not found (where X.X.X is the Rokt SDK version), follow [README on *Rokt.Widget* directory](https://github.com/ROKT/rokt-sdk-react-native/tree/release-3.10.x/Rokt.Widget#readme) first

### Start with npx
Make sure you have your Android device or Emulator turned on.
go to *RoktSampleApp* directory and run `npx react-native start --reset-cache`


## iOS

### Install the pod
go to *RoktSampleApp/ios* directory and run `pod install` (if pod install failed, run `pod update` to get the latest libraries)

## Run iOS
Make sure you have your iOS device or Simulator turned on.

1. go to *RoktSampleApp* directory 
2. if you are on an M1 Mac, run `npx react-native start`
3. run `npx react-native run-ios --simulator="[simulator/device name]"` e.g. `npx react-native run-ios --simulator="iPhone 14"`

## Android

### run Android
go to *RoktSampleApp* directory and run `npx react-native run-android` 

## Note
To test the SDK changes locally follow the below steps:
1. Create a package in SDK with a new version. 
2. Go to RoktSampleApp root, modify the ```package.json``` of RoktSampleApp.
3. Delete the ```package-lock.json``` and run the ```npm install``` again.
4. For iOS, go to ios directory and run ``` pod install ```.


# Copyright
Copyright 2020 Rokt Pte Ltd Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); You may not use this file except in compliance with the License. You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/