# Rokt Minimal Sample App

A minimal React Native sample application demonstrating integration with the Rokt SDK. This app contains **only** the essential dependencies needed to run the Rokt React Native SDK, without any unnecessary packages like `react-native-screens` or `@react-navigation`.

## Features

- ✅ Clean, minimal dependency structure
- ✅ Rokt SDK integration examples
- ✅ Initialize and Execute functionality
- ✅ Event listener setup
- ✅ Modern React Native 0.79.4
- ✅ TypeScript support
- ❌ No navigation libraries
- ❌ No extra UI libraries

## Prerequisites

- Node.js >= 18
- React Native development environment set up
  - For iOS: Xcode, CocoaPods
  - For Android: Android Studio, JDK

## Installation

### 1. Install Dependencies

```bash
npm install
```

### 2. iOS Setup

```bash
cd ios
pod install
cd ..
```

### 3. Run the App

**iOS:**
```bash
npm run ios
```

**Android:**
```bash
npm run android
```

## Configuration

Before running the app, you'll need to configure your Rokt credentials:

1. Open the app on your device/simulator
2. Enter your **Rokt Tag ID** in the first input field
3. Configure the **View Name** (e.g., "RoktExperience")
4. Set the **Placeholder Name** (e.g., "Location1")
5. Fill in customer attributes (email, firstname, lastname)
6. Tap **Initialize** to initialize the Rokt SDK
7. Tap **Execute** to load Rokt placements

## App Structure

```
RoktMinimalSampleApp/
├── App.tsx                 # Main app component with Rokt integration
├── index.js                # Entry point
├── package.json            # Dependencies (minimal set)
├── babel.config.js         # Babel configuration
├── metro.config.js         # Metro bundler configuration
├── tsconfig.json           # TypeScript configuration
├── android/                # Android native code
└── ios/                    # iOS native code
```

## Dependencies

### Production Dependencies
- `react`: ^19.0.0
- `react-native`: ^0.79.4
- `@rokt/react-native-sdk`: Local package from `../Rokt.Widget`

### Development Dependencies
Standard React Native dev tools (Babel, ESLint, TypeScript, Jest, etc.)

**No additional libraries** like navigation, state management, or UI frameworks are included.

## Key Features Demonstrated

### 1. SDK Initialization

```typescript
Rokt.setLoggingEnabled(true);
Rokt.setEnvironmentToStage(); // or setEnvironmentToProd()
Rokt.initialize(tagId, appVersion);
```

### 2. Execute Rokt Placements

```typescript
const attributes = {
  email: 'customer@example.com',
  firstname: 'John',
  lastname: 'Doe',
};

const placeholders = {
  'Location1': nodeHandle,
};

Rokt.execute(viewName, attributes, placeholders);
```

### 3. Event Listening

```typescript
const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

eventManagerEmitter.addListener('RoktEvents', (data) => {
  console.log(`Rokt Event: ${JSON.stringify(data)}`);
});
```

### 4. RoktEmbeddedView Component

```typescript
<RoktEmbeddedView
  ref={placeholderRef}
  placeholderName="Location1"
/>
```

## Comparison with RoktSampleApp

| Feature | RoktMinimalSampleApp | RoktSampleApp |
|---------|---------------------|---------------|
| Dependencies | Minimal (3 prod) | Many (6+ prod) |
| Navigation | None | React Navigation installed (not used) |
| UI Libraries | React Native only | Additional checkbox, toast libraries |
| Code Complexity | Simple | More features |
| File Size | Smaller | Larger |
| Best For | Learning, starting point | Full feature demo |

## Troubleshooting

### iOS Build Issues

If you encounter CocoaPods issues:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### Android Build Issues

If you encounter Gradle issues:
```bash
cd android
./gradlew clean
cd ..
```

### Metro Bundler Issues

Clear Metro cache:
```bash
npm start -- --reset-cache
```

## Development

### Linting

```bash
npm run lint
```

### Testing

```bash
npm test
```

## Environment Variables

The app uses Stage environment by default. To switch to Production, modify the `onInitialize` method in `App.tsx`:

```typescript
Rokt.setEnvironmentToProd(); // Instead of setEnvironmentToStage()
```

## Additional Resources

- [Rokt SDK Documentation](https://docs.rokt.com/)
- [React Native Documentation](https://reactnative.dev/)
- [React Native New Architecture](https://reactnative.dev/docs/new-architecture-intro)

## License

Copyright 2020 Rokt Pte Ltd

## Support

For issues with:
- **Rokt SDK**: Contact Rokt support
- **React Native**: Check React Native documentation
- **This Sample App**: Open an issue in the repository


