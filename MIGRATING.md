# Migration Guide

This document provides guidance on migrating to newer versions of the Rokt React Native SDK.

## Migrating from v4.x to v5.0.0

v5.0.0 is a major release that aligns the React Native SDK with native iOS SDK 5.0 and Android SDK 5.0. This includes API renames, removal of deprecated methods, and new Shoppable Ads support.

### Breaking Changes

#### API Renames

| v4.x                                    | v5.0.0                                               |
| --------------------------------------- | ---------------------------------------------------- |
| `Rokt.execute(viewName, ...)`           | `Rokt.selectPlacements(identifier, ...)`             |
| `Rokt.executeWithConfig(viewName, ...)` | `Rokt.selectPlacements(identifier, ..., roktConfig)` |
| `Rokt.execute2Step(viewName, ...)`      | Removed — use `selectPlacements()`                   |

The `viewName` parameter has been renamed to `identifier` across all APIs.

#### Removed APIs

The following methods have been removed in v5.0.0:

| Removed Method                    | Replacement                                             |
| --------------------------------- | ------------------------------------------------------- |
| `Rokt.execute()`                  | `Rokt.selectPlacements()`                               |
| `Rokt.execute2Step()`             | `Rokt.selectPlacements()`                               |
| `Rokt.setLoggingEnabled()`        | No replacement — use native SDK log level configuration |
| `Rokt.setFulfillmentAttributes()` | Removed                                                 |
| `Rokt.setSessionId()`             | Removed                                                 |
| `Rokt.getSessionId()`             | Removed                                                 |

#### Event System Changes

The callback architecture has been unified. Individual callbacks (`onLoad`, `onUnLoad`, `onShouldShowLoadingIndicator`, etc.) have been replaced with a single event stream. Listen for events via `NativeEventEmitter`:

```js
import { NativeEventEmitter, NativeModules } from "react-native";

const eventEmitter = new NativeEventEmitter(NativeModules.RoktEventManager);

eventEmitter.addListener("RoktEvents", (event) => {
  console.log("Event:", event.event, "Placement:", event.placementId);
});
```

Event types emitted through `RoktEvents`:

- `ShowLoadingIndicator`, `HideLoadingIndicator`
- `PlacementReady`, `PlacementInteractive`, `PlacementCompleted`, `PlacementClosed`, `PlacementFailure`
- `OfferEngagement`, `PositiveEngagement`
- `InitComplete` (with `status` field)
- `OpenUrl` (with `url` field)
- `CartItemInstantPurchase` (Shoppable Ads — with cart/catalog details)

### Code Migration Examples

#### Before (v4.x)

```js
import { Rokt, RoktEmbeddedView } from "@rokt/react-native-sdk";

// Initialize
Rokt.initialize("YOUR_ROKT_TAG_ID", "1.0");

// Overlay placement
Rokt.execute("RoktExperience", attributes, null, () => console.log("Loaded"));

// Embedded placement
const placeholders = {
  RoktEmbedded1: findNodeHandle(this.placeholder1.current),
};
Rokt.execute("RoktEmbeddedExperience", attributes, placeholders, () =>
  console.log("Loaded"),
);

// Two-step execution
Rokt.execute2Step("RoktExperience", attributes, placeholders, () =>
  console.log("Loaded"),
);
```

#### After (v5.0.0)

```js
import { Rokt, RoktEmbeddedView } from "@rokt/react-native-sdk";

// Initialize (unchanged)
Rokt.initialize("YOUR_ROKT_TAG_ID", "1.0");

// Overlay placement
Rokt.selectPlacements("RoktExperience", attributes, {});

// Embedded placement
const placeholders = {
  RoktEmbedded1: findNodeHandle(this.placeholder1.current),
};
Rokt.selectPlacements("RoktEmbeddedExperience", attributes, placeholders);

// With config
import { RoktConfigBuilder } from "@rokt/react-native-sdk";

const config = new RoktConfigBuilder().withColorMode("dark").build();

Rokt.selectPlacements("RoktExperience", attributes, placeholders, config);

// Listen for events (replaces onLoad callback)
const eventEmitter = new NativeEventEmitter(NativeModules.RoktEventManager);
eventEmitter.addListener("RoktEvents", (event) => {
  switch (event.event) {
    case "PlacementReady":
      console.log("Placement loaded:", event.placementId);
      break;
    case "PlacementClosed":
      console.log("Placement closed");
      break;
  }
});
```

### New: Shoppable Ads

v5.0.0 adds support for Shoppable Ads (Post-Purchase Upsell):

```js
Rokt.selectShoppableAds("ConfirmationPage", {
  email: "j.smith@example.com",
  confirmationref: "ORD-123",
  amount: "52.25",
  currency: "USD",
});
```

> **Note:** Shoppable Ads is currently supported on iOS only. On Android, `selectShoppableAds` is a no-op that logs a warning.

#### Payment Extension (iOS Native Setup)

Shoppable Ads requires registering a payment extension in your iOS AppDelegate. This must be done in native Swift code — it cannot be called from JavaScript:

```swift
// AppDelegate.swift
import Rokt_Widget
import RoktPaymentExtension

// After SDK initialization:
let stripeExt = RoktStripePaymentExtension(
    applePayMerchantId: "merchant.com.yourapp"
)
Rokt.registerPaymentExtension(stripeExt, config: [
    "stripeKey": "pk_live_your_stripe_key"
])
```

### iOS Configuration Changes

#### CocoaPods

The Rokt SDK 5.0 ships as source-based Swift pods. To avoid module map conflicts with React Native's new architecture, your Podfile needs a `pre_install` hook for dynamic framework linking:

```ruby
# Add before your target block
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

#### Expo

If you're using Expo, the `@rokt/react-native-sdk` config plugin handles this automatically. Add it to your `app.json`:

```json
{
  "expo": {
    "plugins": ["@rokt/react-native-sdk"]
  }
}
```

Then run `npx expo prebuild --clean` to regenerate native projects.

### Minimum Platform Requirements

| Platform     | v4.x    | v5.0.0  |
| ------------ | ------- | ------- |
| iOS          | 10.0    | 15.0    |
| Android      | 21      | 21      |
| React Native | 0.55.4+ | 0.71.0+ |
