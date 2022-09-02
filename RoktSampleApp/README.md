


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
| release |  [![CircleCI](https://dl.circleci.com/status-badge/img/gh/ROKT/rokt-sdk-react-native/tree/release-3.8.x.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/ROKT/rokt-sdk-react-native/tree/release-3.8.x)
### Note
Modify the Circleci url whenever default branch is changed.

## CI/CD System

The CI system used is  **CircleCi**  [https://app.circleci.com/pipelines/github/ROKT/rokt-sdk-react-native](https://app.circleci.com/pipelines/github/ROKT/rokt-sdk-react-native)  CircleCi workflows are defined in the  `.circleci`  directory. The iOS step build the app and run the UI test in the CircleCi environment whereas Android step builds the apk in the circleCi environment whereas the UI test is executed in device farm using the fastlane lane ```deviceFarmUITest``` defined in the directory ```RoktSampleApp/android```

## Local Setup

### NPM install on Sample app
go to *RoktSampleApp* directory and run `npm install`

### Start with npx
Make sure you have your Android device or Emulator turned on.
go to *RoktSampleApp* directory and run `npx react-native start --reset-cache`


## iOS

### Install the pod
go to *RoktSampleApp/iOS* directory and run `pod install` (if pod install failed, rund `pod update` to get the latest libraries)

## run iOS
Make sure you have your iOS device or Simulator turned on.
go to *RoktSampleApp* directory and run `npx react-native run-ios` 

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