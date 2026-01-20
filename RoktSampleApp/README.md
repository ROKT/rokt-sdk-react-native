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

- **Node.js** (v14+), **npm**, and **React Native CLI** (`npm install -g react-native-cli`)
- **iOS:** macOS, Xcode, CocoaPods, and iOS Simulator/device
- **Android:** Android Studio with SDK, and Emulator/device with USB debugging

### First-Time Setup

#### 1. Build the Rokt Widget Package

```bash
cd Rokt.Widget
npm install
npm run build
npm pack
```

> [!NOTE]
> This creates `rokt-react-native-sdk-X.X.X.tgz` file that the sample app will use.

#### 2. Install Sample App Dependencies

```bash
cd ../RoktSampleApp
npm install
```

#### 3. iOS Setup

Navigate to the iOS directory and install CocoaPods dependencies:

```bash
cd ios
```

Choose one of the following commands:

**Option A:** Direct pod install (use if you encounter Ruby 3.4+ issues)

```bash
pod install --repo-update
```

**Option B:** Using bundler for version management

```bash
bundle exec pod install --repo-update
```

Then return to the RoktSampleApp directory:

```bash
cd ..
```

> [!WARNING]
> Ruby 3.4+ with `bundle exec` may fail due to missing `kconv`. Use Option A, downgrade to Ruby 3.3.x, or add `gem 'nkf'` to Gemfile with `export LANG=en_US.UTF-8`.

### Running the Sample App

#### iOS

1. Start iOS Simulator (Xcode → Open Developer Tool → Simulator) or connect device
2. From `RoktSampleApp`, run:
   ```bash
   npx react-native run-ios --simulator="iPhone 14"
   ```
   Replace `"iPhone 14"` with your simulator name. To see available simulators: `xcrun simctl list devices`

> [!TIP]
> **M1 Macs:** If you encounter architecture issues, start Metro bundler first in a separate terminal: `npx react-native start --reset-cache`

#### Android

1. From `RoktSampleApp`:
   ```bash
   npx react-native run-android  # Starts Metro bundler automatically
   ```

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

> [!TIP]
> The `--reset-cache` flag is especially useful when adjusting the React Native version or experiencing build issues.

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

## Copyright

Copyright 2020 Rokt Pte Ltd Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); You may not use this file except in compliance with the License. You may obtain a copy of the License at <https://rokt.com/sdk-license-2-0/>
