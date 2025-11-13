# Quick Start Guide

Get the Rokt Minimal Sample App running in minutes!

## Prerequisites

- Node.js 18 or higher
- Xcode (for iOS)
- Android Studio (for Android)

## Setup Steps

### 1. Install Dependencies

```bash
cd RoktMinimalSampleApp
npm install
```

### 2. iOS Setup

```bash
cd ios
pod install
cd ..
```

### 3. Run the App

**For iOS:**
```bash
npm run ios
```

**For Android:**
```bash
npm run android
```

## First Use

1. **Enter your Rokt Tag ID** - Get this from your Rokt dashboard
2. **Click Initialize** - This sets up the Rokt SDK
3. **Click Execute** - This loads Rokt placements

## What's Different from RoktSampleApp?

This minimal app has:
- ✅ **Only 3 production dependencies** (vs 6+ in RoktSampleApp)
- ✅ **No navigation libraries** (react-native-screens, @react-navigation)
- ✅ **No extra UI libraries** (toast-message, checkbox)
- ✅ **No encryption examples** (simpler code)
- ✅ **Cleaner, easier to understand code**

## Package Comparison

### RoktMinimalSampleApp (3 dependencies)
```json
{
  "@rokt/react-native-sdk": "local",
  "react": "19.0.0",
  "react-native": "0.79.4"
}
```

### RoktSampleApp (6+ dependencies)
```json
{
  "@react-native-community/checkbox": "^0.5.12",
  "@rokt/react-native-sdk": "local",
  "crypto-js": "^4.0.0",
  "node-forge": "^1.3.1",
  "react": "19.0.0",
  "react-native": "0.79.4",
  "react-native-toast-message": "2.1.5"
}
```

Plus `react-native-screens` and `@react-navigation/*` packages are installed in node_modules but not used.

## Troubleshooting

### "Bundle identifier" error (iOS)
Open `RoktMinimalSampleApp.xcworkspace` in Xcode and set your development team.

### "SDK location not found" (Android)
Create `android/local.properties`:
```
sdk.dir=/Users/YOUR_USERNAME/Library/Android/sdk
```

### Metro bundler cache issues
```bash
npm start -- --reset-cache
```

## Next Steps

- Customize the UI in `App.tsx`
- Add your own customer attributes
- Configure multiple placeholders
- Test with your Rokt experiences

## Support

- Rokt SDK Docs: https://docs.rokt.com/
- React Native Docs: https://reactnative.dev/

Happy coding! 🚀


