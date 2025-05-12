


# React Native 

## Resident Experts

- Thomson Thomas - thomson.thomas@rokt.com
- James Newman - james.newman@rokt.com

## Overview
The RoktSampleApp includes bare-minimum UI to demonstrate the usage of React Native SDK for our partners and testing
The application includes the common functionality in the ```*.js files``` whereas the platform specific code is written in the respective platform package example ```android or ios```.
We use ```npm``` package manager to manage the dependencies for the project.


| Environment | Build |
| ----------- | :----- |
| release |  [![Build status](https://badge.buildkite.com/e75677bd3c8e83f1da750aa9124df1f418f211c9c630765ffd.svg)](https://buildkite.com/rokt/react-native-sdk)

## CI/CD System

The CI system used is  **Buildkite**  [https://buildkite.com/rokt/react-native-sdk/](https://buildkite.com/rokt/react-native-sdk/) Buildkite workflows are defined in the  `.buildkite`  directory. In the iOS step, we build the app and run UI tests in the Buildkite environment. For Android, we create the APK within Buildkite, and then perform UI tests on a device farm.   This is done by using the deviceFarmUITest Fastlane lane located in the directory `RoktSampleApp/android`.

## Local Setup

### NPM install on Sample app
1. Go to *RoktSampleApp* directory
2. `npm install`

To clear the cache, delete `node_modules` and `package-lock.json` and re-run `npm install`

### Start with npx
Make sure you have your Android device or Emulator turned on.
go to *RoktSampleApp* directory and run `npx react-native start --reset-cache`


## iOS

### Install the pod
go to *RoktSampleApp/ios* directory and run `bundle exec pod install --repo-update` 
if pod install failed from rokt-react-native-sdk podfile, run `bundle exec pod update Rokt-Widget`

## Run iOS
Make sure you have your iOS device or Simulator turned on.

1. go to *RoktSampleApp* directory 
2. if you are on an M1 Mac, run `npx react-native start`
3. run `npx react-native run-ios --simulator="[simulator/device name]"` e.g. `npx react-native run-ios --simulator="iPhone 14"`

## Android

### run Android
go to *RoktSampleApp* directory and run `npx react-native run-android` 

## Note
To test the SDK changes locally

### Update version of Rokt Widget. 
1. Go to *Rokt.Widget* directory
2. change the version ```X.X.X``` in ```package.json``` to a new version. 
3. `npm install`
4. `npm run build` to build the `dist` folder
5. `npm pack` to build the new ```rokt-react-native-sdk-X.X.X.tgz```
6. go to `RoktSampleApp` project ```package.json``` to point to ```rokt-react-native-sdk-X.X.X.tgz``` file

# Copyright
Copyright 2020 Rokt Pte Ltd Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); You may not use this file except in compliance with the License. You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/