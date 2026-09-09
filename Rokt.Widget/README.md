# @rokt/react-native-sdk

The Rokt React Native SDK lets you integrate Rokt into your React Native apps. It is a
thin wrapper over the native Rokt iOS and Android SDKs — lightweight, secure, and simple
to integrate.

> **Full integration guide:** this page is a quick reference. For the complete guide
> (iOS `pre_install` setup, Expo, Shoppable Ads, event handling, and config options), see
> the [repository README](https://github.com/ROKT/rokt-sdk-react-native/blob/main/README.md).
> Upgrading from v4.x? See the
> [Migration Guide](https://github.com/ROKT/rokt-sdk-react-native/blob/main/MIGRATING.md).

## Minimum Requirements

| Platform     | Version |
| ------------ | ------- |
| iOS          | 15.0    |
| Android      | API 21  |
| React Native | 0.71.0+ |

## Development Environment

Set up React Native by following the official
[Set Up Your Environment](https://reactnative.dev/docs/set-up-your-environment) guide.
For iOS you also need [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) —
install it via the official instructions (RubyGems is recommended over Homebrew).

## Installation

```shell
npm install @rokt/react-native-sdk --save
```

- **Android** resolves automatically from Maven Central via React Native autolinking — no
  extra configuration.
- **iOS** requires a `pre_install` hook in your Podfile (bare React Native) or the bundled
  Expo config plugin. See the
  [repository README](https://github.com/ROKT/rokt-sdk-react-native/blob/main/README.md#ios-configuration)
  for the exact setup.

## Quick Start

```javascript
import { Rokt, RoktEmbeddedView } from "@rokt/react-native-sdk";

// Initialize once (e.g. on app start)
Rokt.initialize("YOUR_ROKT_TAG_ID", "1.0");

const attributes = {
  email: "j.smith@example.com",
  firstname: "Jenny",
  lastname: "Smith",
  mobile: "(323) 867-5309",
  postcode: "90210",
  country: "US",
};
```

### Overlay placement

```javascript
Rokt.selectPlacements("RoktExperience", attributes, {});
```

### Embedded placement

```tsx
// Create a ref for the embedded view
const placeholderRef = React.createRef();

// In your JSX:
<RoktEmbeddedView ref={placeholderRef} placeholderName="RoktEmbedded1" />;

// Execute with placeholders:
const placeholders = {
  RoktEmbedded1: findNodeHandle(placeholderRef.current),
};

Rokt.selectPlacements("RoktEmbeddedExperience", attributes, placeholders);
```

#### Custom Base URL (CNAME)

Route SDK requests through a partner-owned CNAME. Must be called **before** `Rokt.initialize(...)`. iOS only.

```javascript
Rokt.setCustomBaseURL("https://rokt.example.com");
Rokt.initialize("xxxxxxxx", "1.0");
```

#### Payment callback URL scheme (iOS)

Register the host app's URL scheme and forward incoming deep-link URLs to the SDK so redirect-based payment authentication can resume.

```javascript
import { Linking } from "react-native";

Rokt.setPaymentCallbackURLScheme("myapp");

Linking.addEventListener("url", ({ url }) => {
  Rokt.handleURLCallback(url);
});
```

The scheme must also be declared under `CFBundleURLTypes`/`CFBundleURLSchemes` in `Info.plist` (or `expo.scheme` in `app.json` for Expo).

> **Note:** `execute()` was removed in v5.0.0 — use `selectPlacements()` instead. See the
> [Migration Guide](https://github.com/ROKT/rokt-sdk-react-native/blob/main/MIGRATING.md).

## Development

This directory is the publishable npm package.

1. Make code changes in `src/`.
2. Build the package: `npm run build`.
3. Test with the sample apps in the repo root (`RoktSampleApp`, `ExpoTestApp`).

The package is published to npm automatically via GitHub Actions when the repo's `VERSION`
file is updated on `main`.

## License

Copyright 2020 Rokt Pte Ltd

Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License");
You may not use this file except in compliance with the License.
You may obtain a copy of the License at <https://rokt.com/sdk-license-2-0/>
