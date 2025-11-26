# Expo Test App for Rokt React Native SDK

This is an Expo managed workflow test application for validating the Rokt React Native SDK integration with Expo.

## Prerequisites

- Node.js 18+
- Expo CLI
- iOS Simulator (for iOS testing) or Xcode
- Android Emulator (for Android testing) or Android Studio

## Setup

1. Install dependencies:

```bash
npm install
```

2. Generate native projects with expo prebuild:

```bash
npm run prebuild
```

This will generate the `ios` and `android` directories with native code.

## Running the App

### iOS

```bash
npm run ios
```

Or open `ios/ExpoTestApp.xcworkspace` in Xcode and run from there.

### Android

```bash
npm run android
```

Or open the `android` directory in Android Studio and run from there.

## Testing the Integration

1. **Initialize**: Enter your Rokt Tag ID and tap "Initialize SDK"
2. **Execute**: After initialization, tap "Execute Placement" to display a Rokt placement

## How Integration Works

The Rokt SDK integrates seamlessly with Expo through standard React Native autolinking:

### Android

- **Autolinking**: `RNRoktWidgetPackage` is automatically registered via React Native autolinking
- **Dependencies**: The Rokt native SDK is available from Maven Central (no custom repository needed)

### iOS

- **Autolinking**: The SDK's podspec is automatically discovered
- **Dependencies**: `Rokt-Widget` pod is resolved via CocoaPods

## Verifying the Integration

After running `npm run prebuild`, you can verify the SDK is properly linked:

### Android

- The autolinking configuration should include `@rokt/react-native-sdk` in the generated build files

### iOS

- Check `ios/Podfile.lock` should include:
  - `rokt-react-native-sdk`
  - `Rokt-Widget`

## Important Notes

- This app cannot run in Expo Go because it requires custom native code
- Use `expo run:ios` or `expo run:android` to build and run
- For development, use `expo start --dev-client` with a custom development build

## Troubleshooting

### iOS pod install fails

```bash
cd ios && pod install --repo-update
```

### Android build fails

Clean the build:

```bash
cd android && ./gradlew clean
```

### General issues

Try regenerating the native projects:

```bash
npm run prebuild
```
