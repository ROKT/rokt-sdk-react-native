# React Native

## Overview

The RoktSampleApp includes bare-minimum UI to demonstrate the usage of React Native SDK for our partners and testing
The application includes the common functionality in the `*.js files` whereas the platform specific code is written in the respective platform package example `android or ios`.
We use `npm` package manager to manage the dependencies for the project.

## CI/CD System

The CI system used is **GitHub Actions**. Workflows are defined in the `.github/workflows` directory. The CI pipeline includes:

- Code quality checks (Trunk)
- Building and packaging the SDK
- iOS build and test execution
- Android build and test execution

## Local Setup

### NPM install on Sample app

1. Go to _RoktSampleApp_ directory
2. `npm install`

To clear the cache, delete `node_modules` and `package-lock.json` and re-run `npm install`

### Start with npx

Make sure you have your Android device or Emulator turned on.
go to _RoktSampleApp_ directory and run `npx react-native start --reset-cache`

## iOS

### Install the pod

go to _RoktSampleApp/ios_ directory and run `bundle exec pod install --repo-update`
if pod install failed from rokt-react-native-sdk podfile, run `bundle exec pod update Rokt-Widget`

## Run iOS

Make sure you have your iOS device or Simulator turned on.

1. go to _RoktSampleApp_ directory
2. if you are on an M1 Mac, run `npx react-native start`
3. run `npx react-native run-ios --simulator="[simulator/device name]"` e.g. `npx react-native run-ios --simulator="iPhone 14"`

## Android

### run Android

go to _RoktSampleApp_ directory and run `npx react-native run-android`

## Note

To test the SDK changes locally

### Update version of Rokt Widget

1. Go to _Rokt.Widget_ directory
2. change the version `X.X.X` in `package.json` to a new version.
3. `npm install`
4. `npm run build` to build the `dist` folder
5. `npm pack` to build the new `rokt-react-native-sdk-X.X.X.tgz`
6. go to `RoktSampleApp` project `package.json` to point to `rokt-react-native-sdk-X.X.X.tgz` file

# Copyright

Copyright 2020 Rokt Pte Ltd Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); You may not use this file except in compliance with the License. You may obtain a copy of the License at <https://rokt.com/sdk-license-2-0/>
