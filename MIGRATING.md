# Migration Guide

This document provides guidance on migrating to newer versions of the Rokt React Native SDK.

## iOS: the Rokt SDK now comes from Swift Package Manager

`pod install` now links the Rokt iOS SDK into your app target as a Swift package instead of installing it as a pod. React Native and this package still install with CocoaPods. See [README › Swift Package Manager](README.md#swift-package-manager) for the settings and troubleshooting.

Bare React Native apps:

1. In `ios/Podfile`, remove the `pre_install` block that sets dynamic framework linking for `Rokt-Widget`, `RoktContracts`, `RoktUXHelper` and `DcuiSchema`. Keep the block if it lists other pods; just remove those four names.
2. If the Podfile has `pod 'RoktPaymentExtension'`, remove it and add this at the top of the Podfile instead:

   ```ruby
   $RNRoktSPMPackages = ['RoktPaymentExtension']
   ```

3. Run `cd ios && pod install`. It prints `[Rokt] <your app target> <- Rokt-Widget <version>`.
4. Commit the change to your `.xcodeproj` and the `Package.resolved` file that Xcode creates.

Native code is unchanged: `import Rokt_Widget` and `import RoktPaymentExtension` work as before. If you had already added the Rokt iOS SDK to the app target as a Swift package, `pod install` keeps that package and pins its version.

If your app also uses `react-native-mparticle` with its Rokt kit, use its Swift Package Manager mode too. Installed with CocoaPods, that kit adds the Rokt iOS SDK as a pod, and `pod install` stops.

Expo apps: run `npx expo prebuild --clean`.

To keep taking the SDK from CocoaPods for now, set `$RNRoktDisableSPM = true` at the top of the Podfile and keep the `pre_install` block. This mode is deprecated: new versions of the Rokt iOS SDK may not be published to CocoaPods after 2 December 2026.

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
if let paymentExt = RoktPaymentExtension(
    applePayMerchantId: "merchant.com.yourapp"
) {
    Rokt.registerPaymentExtension(paymentExt, config: [
        "stripeKey": "YOUR_STRIPE_PUBLISHABLE_KEY"
    ])
}
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

## Selecting embedded placements by name

Existing numeric placeholder maps continue to work. New integrations can remove
view refs and `findNodeHandle`:

```tsx
<RoktEmbeddedView placeholderName="Location1" />;
Rokt.selectPlacements("MSDKEmbeddedLayout", attributes, ["Location1"]);
```

The SDK waits up to two seconds for requested names to register, then proceeds
with the available views. This supports selection from the same effect that
renders a placeholder. A newer call for the same identifier replaces a pending
call. An old map entry with `null` now resolves by its key, which must match a
view's `placeholderName`. It has the same two-second wait if no matching view
mounts. Positive tags keep legacy lookup without a mount wait. Overlay-only
calls can omit placeholders.

Import `RoktEventManager` from `@rokt/react-native-sdk` when constructing a
`NativeEventEmitter`. The exported manager supports iOS bridgeless hosts with
legacy module interop disabled. Event names and payloads remain unchanged.

Placement attributes now accept `string | number | boolean`. Both platforms
receive numbers and booleans as strings, including `0` and `false`. Null and
unsupported values are ignored; font and cache attribute types are unchanged.

Names are global across React Native hosts. Use distinct names when independent
hosts mount placeholders simultaneously. Within a navigation stack, the newest
attached matching view takes precedence.
