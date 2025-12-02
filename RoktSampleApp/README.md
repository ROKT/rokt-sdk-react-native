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

### Prerequisites

Before setting up the sample app, ensure you have the following installed:

- **Node.js** (v14 or higher) and **npm**
- **React Native CLI** (`npm install -g react-native-cli`)
- **For iOS development:**
  - macOS with Xcode installed
  - CocoaPods (`gem install cocoapods` or use bundler)
  - iOS Simulator or physical device
- **For Android development:**
  - Android Studio with SDK installed
  - Android Emulator or physical device with USB debugging enabled

### First-Time Setup

Follow these steps in order if this is your first time setting up the sample app:

#### Step 1: Build the Rokt Widget Package

The sample app depends on a locally built version of the Rokt Widget SDK.

1. Navigate to the `Rokt.Widget` directory from the project root:
   ```bash
   cd Rokt.Widget
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Build the package:
   ```bash
   npm run build
   ```

4. Create the distributable package:
   ```bash
   npm pack
   ```
   
   This creates `rokt-react-native-sdk-X.X.X.tgz` file that the sample app will use.

#### Step 2: Install Sample App Dependencies

1. Navigate to the `RoktSampleApp` directory from the project root:
   ```bash
   cd ../RoktSampleApp
   ```

2. Install npm dependencies:
   ```bash
   npm install
   ```

#### Step 3: Platform-Specific Setup

Choose the platform(s) you want to run:

##### iOS Setup

1. Navigate to the iOS directory:
   ```bash
   cd ios
   ```

2. Install CocoaPods dependencies using one of the following commands:
   
   **Option A (Recommended):** Using bundler:
   ```bash
   bundle exec pod install --repo-update
   ```
   
   **Option B:** Direct pod install:
   ```bash
   pod install --repo-update
   ```

3. Return to the `RoktSampleApp` directory:
   ```bash
   cd ..
   ```

**Note:** If using `bundle exec` with Ruby 3.4+, the command may fail due to a missing `kconv` library. You can either use Option B above, downgrade to Ruby 3.3.x, or manually add `gem 'nkf'` to the Gemfile and ensure UTF-8 encoding with `export LANG=en_US.UTF-8`.

##### Android Setup

No additional setup is required for Android beyond the standard Android development environment.

### Running the Sample App

#### Running on iOS

1. **Start the iOS Simulator** (or connect a physical device)
   - Open Xcode → Xcode menu → Open Developer Tool → Simulator
   - Or boot your preferred simulator from the command line

2. **From the `RoktSampleApp` directory**, start the Metro bundler (in a separate terminal):
   ```bash
   npx react-native start --reset-cache
   ```

3. **In another terminal**, run the app:
   ```bash
   npx react-native run-ios --simulator="iPhone 14"
   ```
   
   Replace `"iPhone 14"` with your preferred simulator name. To see available simulators:
   ```bash
   xcrun simctl list devices
   ```

**Note for M1 Macs:** If you encounter architecture issues, ensure the Metro bundler is running before executing the `run-ios` command.

#### Running on Android

1. **Start your Android Emulator** (or connect a physical device with USB debugging enabled)
   - Open Android Studio → AVD Manager → Start emulator
   - Or use `adb devices` to verify your device is connected

2. **From the `RoktSampleApp` directory**, run:
   ```bash
   npx react-native run-android
   ```
   
   This will automatically start the Metro bundler if it's not already running.

### Troubleshooting

#### Clearing Caches

If you encounter build issues, try clearing caches:

**npm cache:**
```bash
# From RoktSampleApp directory
rm -rf node_modules package-lock.json
npm install
```

**Metro bundler cache:**
```bash
npx react-native start --reset-cache
```

**iOS cache:**
```bash
# From RoktSampleApp/ios directory
rm -rf Pods Podfile.lock
pod install --repo-update
```

**Note:** The `--reset-cache` flag is especially useful when adjusting the React Native version or experiencing build issues.

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
