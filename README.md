# @rokt/react-native-sdk

## Overview

This repository contains the React Native SDK [Rokt.Widget](Rokt.Widget), a Sample Application [RoktSampleApp](RoktSampleApp), and an Expo Test Application [ExpoTestApp](ExpoTestApp).

The React Native SDK enables you to integrate Rokt into your React Native mobile apps to drive more value from—and for—your customers. The SDK is built to be lightweight, secure, and simple to integrate and maintain, resulting in minimal lift for your engineering team.

For detailed information about each component, please refer to:

- [Rokt.Widget README](Rokt.Widget/README.md) - Documentation for the SDK implementation
- [RoktSampleApp README](RoktSampleApp/README.md) - Guide for the sample application
- [Migration Guide](MIGRATING.md) - Guide for migrating from v4.x to v5.0.0

## Integration Guide

### Installation

```shell
npm install @rokt/react-native-sdk --save
```

### Android Configuration

The Rokt SDK is available from Maven Central and will be resolved automatically via React Native autolinking. No manual repository or package configuration is required.

### iOS Configuration

#### Bare React Native

Add the following `pre_install` block to your `ios/Podfile` before the `target` block. This is required because Rokt SDK 5.0 ships as source-based Swift pods that need dynamic framework linking:

```ruby
pre_install do |installer|
  installer.pod_targets.each do |pod|
    if ['Rokt-Widget', 'RoktContracts', 'RoktUXHelper', 'DcuiSchema'].include?(pod.name)
      def pod.build_type;
        Pod::BuildType.new(:linkage => :dynamic, :packaging => :framework)
      end
    end
  end
end
```

Then install pods:

```shell
cd ios && pod install
```

#### Expo

This package cannot be used with "Expo Go" because it requires custom native code. Use a custom development client instead.

1. Install the required packages:

   ```shell
   npm install @rokt/react-native-sdk expo-dev-client
   ```

2. Add the config plugin to your `app.json` or `app.config.js`:

   ```json
   {
     "expo": {
       "plugins": ["@rokt/react-native-sdk"]
     }
   }
   ```

   > The config plugin automatically configures the iOS Podfile for Rokt SDK compatibility. This is required for Expo projects.

3. Generate the native projects and build:

   ```shell
   npx expo prebuild --clean
   npx expo run:ios   # or npx expo run:android
   ```

## Usage

### Import

```js
import { Rokt, RoktEmbeddedView } from "@rokt/react-native-sdk";
```

### Initialize

```js
Rokt.initialize("YOUR_ROKT_TAG_ID", "1.0");
```

### Select Placements (Overlay)

```js
const attributes = {
  email: "j.smith@example.com",
  firstname: "Jenny",
  lastname: "Smith",
  mobile: "(323) 867-5309",
  postcode: "90210",
  country: "US",
};

Rokt.selectPlacements("RoktExperience", attributes, {});
```

### Select Placements (Embedded)

```js
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

### Select Placements with Config

```js
import { RoktConfigBuilder, CacheConfig } from "@rokt/react-native-sdk";

const config = new RoktConfigBuilder()
  .withColorMode("dark")
  .withCacheConfig(new CacheConfig(5400)) // 90 minutes
  .build();

Rokt.selectPlacements("RoktExperience", attributes, placeholders, config);
```

### Shoppable Ads

Shoppable Ads enables partners to present contextual upsell offers to customers after a purchase. Shoppable Ads use a full-screen overlay — no embedded placeholders are needed.

```js
Rokt.selectShoppableAds("ConfirmationPage", {
  email: "j.smith@example.com",
  confirmationref: "ORD-123",
  amount: "52.25",
  currency: "USD",
});
```

> **Note:** Shoppable Ads is currently supported on iOS only. On Android, `selectShoppableAds` is a no-op.

#### Payment Extension (iOS)

Shoppable Ads requires a payment extension registered in your native iOS AppDelegate:

```swift
// AppDelegate.swift
import Rokt_Widget
import RoktStripePaymentExtension

// After SDK initialization:
if let stripeExt = RoktStripePaymentExtension(
    applePayMerchantId: "merchant.com.yourapp"
) {
    Rokt.registerPaymentExtension(stripeExt, config: [
        "stripeKey": "pk_live_your_stripe_key"
    ])
}
```

### Purchase Finalized

After a shoppable ads purchase completes:

```js
Rokt.purchaseFinalized("placementId", "catalogItemId", true);
```

### Event Handling

Listen for SDK events via `NativeEventEmitter`:

```js
import { NativeEventEmitter, NativeModules } from "react-native";

const eventEmitter = new NativeEventEmitter(NativeModules.RoktEventManager);

const subscription = eventEmitter.addListener("RoktEvents", (event) => {
  switch (event.event) {
    case "InitComplete":
      console.log("SDK initialized:", event.status);
      break;
    case "PlacementReady":
      console.log("Placement ready:", event.placementId);
      break;
    case "PlacementClosed":
      console.log("Placement closed");
      break;
    case "CartItemInstantPurchase":
      console.log("Purchase:", event.catalogItemId, event.totalPrice);
      break;
  }
});

// Clean up
subscription.remove();
```

### Environment Configuration

```js
Rokt.setEnvironmentToStage(); // For testing
Rokt.setEnvironmentToProd(); // For production (default)
```

## API Reference

| Method                                                                 | Description                            |
| ---------------------------------------------------------------------- | -------------------------------------- |
| `Rokt.initialize(tagId, appVersion, fontFilesMap?)`                    | Initialize the SDK                     |
| `Rokt.selectPlacements(identifier, attributes, placeholders, config?)` | Display overlay or embedded placements |
| `Rokt.selectShoppableAds(identifier, attributes, config?)`             | Display shoppable ads (iOS only)       |
| `Rokt.purchaseFinalized(placementId, catalogItemId, success)`          | Report purchase completion             |
| `Rokt.setEnvironmentToStage()`                                         | Set staging environment                |
| `Rokt.setEnvironmentToProd()`                                          | Set production environment             |
| `Rokt.setSessionId(sessionId)`                                         | Set a custom session ID                |
| `Rokt.getSessionId()`                                                  | Get the current session ID             |

## Minimum Requirements

| Platform     | Version |
| ------------ | ------- |
| iOS          | 15.0    |
| Android      | API 21  |
| React Native | 0.71.0+ |

## Development

### Local Development

1. Make code changes in `Rokt.Widget/`
2. Build the package: `cd Rokt.Widget && npm run build`
3. Test using the sample apps:
   - `cd RoktSampleApp && npm install && npm run ios`
   - `cd RoktSampleApp && npm install && npm run android`

### Publishing

The SDK is published to NPM automatically via GitHub Actions when the `VERSION` file is updated on `main`.

## License

Copyright 2020 Rokt Pte Ltd

Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License");
You may not use this file except in compliance with the License.
You may obtain a copy of the License at <https://rokt.com/sdk-license-2-0/>
