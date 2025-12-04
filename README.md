# @rokt/react-native-sdk

## Overview

This repository contains the React Native SDK [Rokt.Widget](Rokt.Widget) and a Sample Application [RoktSampleApp](RoktSampleApp).

The React Native SDK enables you to integrate Rokt into your React Native mobile apps to drive more value from—and for—your customers. The SDK is built to be lightweight, secure, and simple to integrate and maintain, resulting in minimal lift for your engineering team. The RoktSampleApp includes bare-minimum UI to demonstrate the usage of React Native SDK for partners.

For detailed information about each component, please refer to:

- [Rokt.Widget README](Rokt.Widget/README.md) - Documentation for the SDK implementation
- [RoktSampleApp README](RoktSampleApp/README.md) - Guide for the sample application

## Service Architecture

The React Native SDK uses a bridge architecture to connect your JavaScript/TypeScript application code to the native Rokt Widget SDK implementations:

### Bridge Architecture

#### TypeScript Layer

- **API Interface**: The SDK provides a TypeScript interface in `Rokt.tsx` that exports methods like `initialize()`, `execute()`, and `execute2Step()`
- **Module Definition**: The TypeScript layer defines a `RNRoktWidget` interface that maps to the native modules

#### Native Bridge Implementation

##### iOS Implementation

- **Swift Bridge Classes**:
  - `RNRoktWidget`: Main bridge class implementing `RCTBridgeModule` that exports methods to React Native
  - `RoktEventManager`: Handles events and callbacks between the Swift implementation and JavaScript
  - The bridge translates React Native method calls to the corresponding native Rokt iOS SDK methods

##### Android Implementation

- **Kotlin Bridge Classes**:
  - `RNRoktWidgetModule`: Main Kotlin class that extends `ReactContextBaseJavaModule` to implement the bridge
  - `RoktEmbeddedViewManager`: Manages embedded view components and UI rendering
  - The module takes React Native parameters and converts them to the format needed by the native Rokt Android SDK

When you call methods from the TypeScript layer, the following happens:

1. Your JavaScript/TypeScript code invokes methods on the `Rokt` object
2. The React Native bridge serializes parameters and routes the call to the appropriate native module (`RNRoktWidget` on iOS or `RNRoktWidgetModule` on Android)
3. The native module translates the call to the corresponding native Rokt Widget SDK method (e.g., `Rokt.initialize()`, `Rokt.execute()`)
4. Results and callbacks are serialized and passed back through the bridge to your JavaScript code

### Workflow

1. **Initialization**: Call `Rokt.initialize()` with your ROKT_TAG_ID to prepare the SDK
2. **Placement Execution**: Call `Rokt.execute()` with template and user attributes to fetch and display Rokt content
3. **Callback Handling**: Process the onLoad callback once content is loaded

Behind the scenes, the SDK handles:

- API communication with Rokt's backend services
- Content rendering in the appropriate placement locations
- Event tracking and user interaction

The sample application demonstrates both placement types with a minimal implementation that you can use as a reference.

## Development Environment Setup

1. Install ReactNative development environment by following the [React Native environment setup instructions](https://reactnative.dev/docs/environment-setup).
2. This project requires a minimum `Ruby` version `2.7.6`. Check by running `ruby -v` in your terminal.
3. Clone this repository to your local machine.
4. Run `npm install` to install all dependencies.

### Android Setup

Make sure you have Android Studio installed and properly configured with the required SDK versions.

### iOS Setup

For iOS development, ensure you have:

- Xcode installed
- CocoaPods installed (`sudo gem install cocoapods`)

## Making Changes and Deployment

### Local Development

1. Make your code changes in the appropriate files
2. Test changes using the RoktSampleApp:
   - Android: `npx react-native run-android`
   - iOS: `npx react-native run-ios`

### Publishing

This SDK is published to a NPM package repository. Publishing is automated through GitHub Actions workflows.

#### Automated Publishing

The SDK is automatically published to NPM when the `VERSION` file is updated and pushed to the `main` branch. The GitHub Actions workflow (`release-from-main.yml`) handles:

- Building and testing the package
- Running iOS and Android tests
- Publishing to NPM with the appropriate dist tag
- Creating a GitHub release

To create a new release:

1. Use the "Create draft release" workflow to bump the version (major, minor, or patch)
2. Review and merge the generated pull request
3. Once merged to `main`, the release workflow will automatically publish to NPM

The appropriate dist tag will be applied automatically when publishing if one is set (e.g. `1.2.3-alpha.1` will set the dist tag as `alpha`). If not, the default `latest` tag will be used.

You can also release the SDK manually by following the steps in the above section.

## Integration Guide

To add this SDK to your application:

1. Go to the root of your project in your terminal and run:

   ```shell
   npm install @rokt/react-native-sdk --save
   npm install
   ```

### Android Configuration

The Rokt SDK is available from Maven Central and will be resolved automatically via React Native autolinking. No manual repository or package configuration is required.

Ensure your app meets the minimum requirements:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### iOS Configuration

#### Install the pods

Navigate to the iOS folder and run:

```shell
pod install
```

### Expo

This package cannot be used with the "Expo Go" app because it requires custom native code.
Integration with Expo is supported in both bare workflow and managed workflow.

#### Bare Workflow

No additional configuration is required. React Native autolinking will automatically set up the SDK.

#### Managed Workflow

Since Expo Go does not support custom native code, you need to use a custom development client.

1. Install the required packages:

   ```shell
   npm install @rokt/react-native-sdk expo-dev-client
   ```

2. (Optional) Add the config plugin to your `app.json` or `app.config.js`:

   ```json
   {
     "expo": {
       "plugins": ["@rokt/react-native-sdk"]
     }
   }
   ```

   > Note: The config plugin is optional as React Native autolinking handles the native setup automatically.

3. Generate the native projects and build:

   ```shell
   npx expo prebuild --clean
   npx expo run:ios   # or npx expo run:android
   ```

For production builds, you can use [EAS Build](https://docs.expo.dev/build/introduction/) which will handle the native compilation automatically.

## Usage

### Initialising the SDK

The Rokt Module provides two methods:

1. `initialize(string ROKT_TAG_ID, string AppVersion)`
2. `execute(string TemplateVersion, object UserAttributes, object placements, function onLoad)`

The Initialize Method will fetch API results that Execute Method would need, so best not to place both calls next to each other.

#### Import

```js
import { Rokt, RoktEmbeddedView } from "@rokt/react-native-sdk";
```

#### Initialize

```js
Rokt.initialize("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "1.0");
```

### To launch Overlay placement

#### Execute Overlay

```js
attributes = {
  email: "j.smith@example.com",
  firstname: "Jenny",
  lastname: "Smith",
  mobile: "(323) 867-5309",
  postcode: "90210",
  country: "US",
};
Rokt.execute("RoktExperience", attributes, null, () =>
  console.log("Placement Loaded"),
);
```

### To launch Embedded placement

#### Create placeholder

```js
constructor(props) {
  super(props);
  this.placeholder1 = React.createRef();
}
```

In render():

```js
<RoktEmbeddedView
  ref={this.placeholder1}
  placeholderName={"RoktEmbedded1"}
></RoktEmbeddedView>
```

#### Execute Embedded

```js
placeholders = {
  RoktEmbedded1: findNodeHandle(this.placeholder1.current),
};

attributes = {
  email: "j.smith@example.com",
  firstname: "Jenny",
  lastname: "Smith",
  mobile: "(323) 867-5309",
  postcode: "90210",
  country: "US",
};
Rokt.execute("RoktEmbeddedExperience", attributes, placeholders, () =>
  console.log("Placement Loaded"),
);
```

## Key Dependencies & Gotchas

### Dependencies

- React Native (core dependency)
- Native modules for both Android and iOS platforms
- For Android: Rokt SDK from Maven Central (resolved automatically)
- For iOS: Rokt-Widget pod (resolved automatically via CocoaPods)

### Mac M1 Machine Configuration

When developing on Mac M1 machines, follow these additional steps:

1. Make sure cocoa pods are installed using gem not brew:

```shell
brew uninstall cocoapods
brew uninstall --ignore-dependencies ruby
sudo gem install cocoapods
```

### Common Issues

1. When integrating with an existing app, ensure the React Native version is compatible with the SDK.
2. For Android, MultiDex is required as the SDK increases method count.
3. For iOS, ensure CocoaPods is properly installed and initialized.
4. Always call `initialize()` before `execute()` and allow sufficient time between the calls.

## License

Copyright 2020 Rokt Pte Ltd

Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License");
You may not use this file except in compliance with the License.
You may obtain a copy of the License at <https://rokt.com/sdk-license-2-0/>
