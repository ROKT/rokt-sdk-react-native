# Phase 1: SDK Bridge & Events - Context

**Gathered:** 2026-04-14
**Status:** Ready for planning
**Source:** User requirements + mParticle reference implementation + Rokt integration guide

<domain>
## Phase Boundary

This phase updates the Rokt React Native SDK to support Shoppable Ads by:

1. Bumping the iOS SDK dependency from 4.x to 5.0.0
2. Adding `selectShoppableAds` API method to the RN bridge
3. Updating event handling for new shoppable ads event types
4. Android side is no-op stubs only
5. Updating the RoktConfig building to use the new SDK 5.0 builder pattern

This does NOT include example app changes (Phase 2).

</domain>

<decisions>
## Implementation Decisions

### SDK Version Update

- iOS podspec: Change `s.dependency "Rokt-Widget", ">= 4.15", "< 5"` to `s.dependency "Rokt-Widget", ">= 5.0.0"`
- iOS SPM: Change `minimumVersion: '4.15.0'` to `minimumVersion: '5.0.0'`
- Android SDK version stays at 4.14.1 — no change
- iOS platform minimum likely needs to be raised (check SDK 5.0.0 requirements)

### New API: selectShoppableAds

- The direct Rokt SDK (not mParticle) uses `Rokt.selectShoppableAds(identifier:attributes:config:onEvent:)`
- In the RN bridge, this needs to be exposed similarly to `execute` but WITHOUT placeholders (shoppable ads don't use embedded views — they use a full-screen overlay)
- Method signature in TurboModule spec: `selectShoppableAds(identifier: string, attributes: { [key: string]: string }, roktConfig?: RoktConfigType): void`
- Public API in Rokt.tsx: `static selectShoppableAds(identifier: string, attributes: Record<string, string>, roktConfig?: IRoktConfig): void`

### registerPaymentExtension is NOT exposed through the RN bridge

- IMPORTANT: registerPaymentExtension requires native Swift/ObjC code to create the RoktStripePaymentExtension object
- This CANNOT be done from JavaScript — it requires importing the RoktStripePaymentExtension Swift package and instantiating with Apple Pay merchant ID
- registerPaymentExtension is called in the native AppDelegate, NOT through the RN bridge
- The RN bridge only needs `selectShoppableAds` — payment extension registration is a native-only concern
- This is a key difference from mParticle where `registerPaymentExtension` IS on the bridge because mParticle Core SDK wraps it

### iOS Native Bridge Implementation (RNRoktWidget.mm)

- Add `selectShoppableAds` method to both old arch (RCT_EXPORT_METHOD) and new arch (NativeRoktWidgetSpec)
- The implementation calls `[Rokt selectShoppableAds:identifier attributes:attributes config:roktConfig onEvent:^(RoktEvent *event) { ... }]`
- Event callback feeds into existing RoktEventManager
- RoktConfig building may need updating from direct property assignment to builder pattern (like mParticle did: MPRoktConfig → RoktConfigBuilder → build)

### SDK 5.0 API Changes (from mParticle reference)

- `MPRoktConfig` → `RoktConfig` (new namespace)
- Config built via `RoktConfigBuilder` → `colorMode:` → `cacheConfig:` → `build`
- `MPColorMode` → `RoktColorMode` (RoktColorModeDark, RoktColorModeLight, RoktColorModeSystem)
- `MPRoktEmbeddedView` → `RoktEmbeddedView`
- `MPRoktEvent` → `RoktEvent`
- `callbacks:` parameter replaced with `onEvent:^(RoktEvent *event)` block
- Event handling moves from individual callback properties to unified onEvent handler
- Need `#import <RoktContracts/RoktContracts-Swift.h>` or equivalent header

### Android No-Op

- Add `selectShoppableAds` method to `RNRoktWidgetModuleImpl.kt` that logs a warning and does nothing
- Add to both old arch and new arch module files
- Add to TurboModule spec (NativeRoktWidget.ts)

### Event System Updates

- The onEvent callback receives `RoktEvent` objects with various types
- New shoppable ads event types that must be forwarded:
  - CartItemInstantPurchaseInitiated
  - CartItemInstantPurchase (already partially handled — exists in current iOS event manager)
  - CartItemInstantPurchaseFailure
  - CartItemDevicePay (with paymentProvider)
  - InstantPurchaseDismissal
- The existing selectPlacements method should also be updated to use onEvent callback pattern instead of individual callback properties (if SDK 5.0 removes the old callback pattern)

### RoktEventManager Updates

- Current iOS RoktEventManager handles events via individual methods
- SDK 5.0 unifies to `onRoktEvents:(RoktEvent *)event viewName:(NSString *)viewName`
- The mParticle reference shows how this works — the event manager takes a RoktEvent and emits the appropriate JS event
- Need to handle the new event types and extract their properties

### Claude's Discretion

- Exact import paths for SDK 5.0 headers (may need to check actual SDK package)
- Whether `selectPlacements` existing callback pattern needs updating for SDK 5.0 compat
- TypeScript type definitions for new event payloads
- Error handling for selectShoppableAds failures

</decisions>

<canonical_refs>

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Current Bridge Implementation

- `Rokt.Widget/src/NativeRoktWidget.ts` — TurboModule spec (add selectShoppableAds here)
- `Rokt.Widget/src/Rokt.tsx` — Public API class (add selectShoppableAds here)
- `Rokt.Widget/ios/RNRoktWidget.mm` — iOS native bridge (add selectShoppableAds here, update RoktConfig)
- `Rokt.Widget/ios/RoktEventManager.m` — iOS event handling (update for new event types + unified onEvent)
- `Rokt.Widget/ios/RoktEventManager.h` — Event manager header

### Android Bridge

- `Rokt.Widget/android/src/main/java/com/rokt/reactnativesdk/RNRoktWidgetModuleImpl.kt` — Core impl (add no-op)
- `Rokt.Widget/android/src/newarch/java/com/rokt/reactnativesdk/RNRoktWidgetModule.kt` — New arch wrapper
- `Rokt.Widget/android/src/oldarch/java/com/rokt/reactnativesdk/RNRoktWidgetModule.kt` — Old arch wrapper

### SDK Dependency

- `Rokt.Widget/rokt-react-native-sdk.podspec` — iOS SDK version (change here)
- `Rokt.Widget/android/build.gradle` — Android SDK version (no change)
- `Rokt.Widget/package.json` — Package version

### mParticle Reference (similar changes already done)

- GitHub compare: mParticle/react-native-mparticle main...thomson-t/shoppable-ads-sdk9
- Key patterns: selectShoppableAds bridge method, RoktConfigBuilder usage, onEvent callback, RoktContracts import

</canonical_refs>

<specifics>
## Specific Ideas

### selectShoppableAds API signature (from Rokt integration guide)

```swift
// Direct Rokt SDK (what we call from the RN bridge)
Rokt.selectShoppableAds(
    identifier: String,
    attributes: [String: String],
    config: [String: String]?,
    onEvent: (RoktEvent) -> Void
)
```

### mParticle TurboModule spec addition (reference)

```typescript
selectShoppableAds(
    identifier: string,
    attributes: { [key: string]: string },
    roktConfig?: RoktConfigType
): void;
```

### mParticle Android no-op (reference)

```kotlin
fun selectShoppableAds(
    identifier: String,
    attributes: ReadableMap?,
    roktConfig: ReadableMap?,
) {
    Logger.warning("selectShoppableAds is not yet supported on Android")
}
```

### Event types from integration guide

| Event                            | Properties                                    |
| -------------------------------- | --------------------------------------------- |
| CartItemInstantPurchaseInitiated | identifier, catalogItemId, cartItemId         |
| CartItemInstantPurchase          | catalogItemId, totalPrice, currency, quantity |
| CartItemInstantPurchaseFailure   | error, catalogItemId                          |
| CartItemDevicePay                | paymentProvider                               |
| InstantPurchaseDismissal         | identifier                                    |

</specifics>

<deferred>
## Deferred Ideas

- Example app integration (Phase 2)
- Android real implementation (v2/separate bet)
- registerPaymentExtension RN bridge method (not needed — native only for direct SDK)

</deferred>

---

_Phase: 01-sdk-bridge-events_
_Context gathered: 2026-04-14 from user requirements + mParticle reference + Rokt docs_
