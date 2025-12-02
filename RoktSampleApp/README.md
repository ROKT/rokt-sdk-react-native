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

### First Time Setup (Required)

**If this is your first time running the sample app, you must build the Rokt Widget package first:**

1. Navigate to the _Rokt.Widget_ directory
2. Run `npm install`
3. Run `npm run build`
4. Run `npm pack`

This creates the local SDK package (`rokt-react-native-sdk-X.X.X.tgz`) that the sample app depends on.

### NPM install on Sample app

1. Go to _RoktSampleApp_ directory
2. `npm install`

To clear the cache, delete `node_modules` and `package-lock.json` and re-run `npm install`

### Start with npx

Make sure you have your Android device or Emulator turned on.
go to _RoktSampleApp_ directory and run `npx react-native start --reset-cache`

## iOS

### Install the pod

Go to _RoktSampleApp/ios_ directory and run either:

```bash
bundle exec pod install --repo-update
```

or

```bash
pod install --repo-update
```

To clear the cache, delete `Podfile.lock` and `Pods` directory, then re-run either `pod install` command.

**Note:** If using `bundle exec` with Ruby 3.4+, the command may fail due to a missing `kconv` library. You can either use the direct `pod install` command above, downgrade to Ruby 3.3.x, or manually add `gem 'nkf'` to the Gemfile and ensure UTF-8 encoding with `export LANG=en_US.UTF-8`.

If pod install failed from rokt-react-native-sdk podfile, run `bundle exec pod update Rokt-Widget`

## Run iOS

**Important:** Make sure you have your iOS device or Simulator booted before running the commands below. The build will fail if no device is booted.

1. go to _RoktSampleApp_ directory
2. if you are on an M1 Mac, run `npx react-native start`
3. run `npx react-native run-ios --simulator="[simulator/device name]"` e.g. `npx react-native run-ios --simulator="iPhone 14"`

## Android

### run Android

go to _RoktSampleApp_ directory and run `npx react-native run-android`

## Testing SDK Changes Locally

If you've made changes to the SDK and want to test them in the sample app:

### Update version of Rokt Widget

1. Go to _Rokt.Widget_ directory
2. Change the version `X.X.X` in `package.json` to a new version
3. Run `npm install`
4. Run `npm run build` to build the `dist` folder
5. Run `npm pack` to create the new `rokt-react-native-sdk-X.X.X.tgz`
6. Go to `RoktSampleApp` project `package.json` and update the dependency to point to the new `rokt-react-native-sdk-X.X.X.tgz` file
7. Run `npm install` in the _RoktSampleApp_ directory to update the dependency

# Copyright

Copyright 2020 Rokt Pte Ltd Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); You may not use this file except in compliance with the License. You may obtain a copy of the License at <https://rokt.com/sdk-license-2-0/>
