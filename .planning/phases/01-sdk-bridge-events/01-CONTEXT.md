# Phase 1: SDK Bridge & Events - Context

**Gathered:** 2026-04-14
**Status:** Ready for planning
**Source:** iOS/Android migration guides + teammate branch + mParticle reference

<domain>
## Phase Boundary

Full v5.0.0 migration of the React Native SDK bridge layer:

1. Bump iOS SDK to Rokt-Widget 5.0.0 and Android SDK to roktsdk 5.0.0
2. Rename execute → selectPlacements across all layers (TS, iOS, Android)
3. Remove deprecated APIs (setLoggingEnabled, execute2Step, setFulfillmentAttributes, setSessionId/getSessionId)
4. Update event system to unified onEvent callback pattern
5. Add selectShoppableAds API on all layers
6. Leverage teammate's `feat/remove-deprecated-functions` branch

Does NOT include example app changes (Phase 2) or documentation (Phase 3).

</domain>

<decisions>
## Implementation Decisions

### Teammate's Branch (feat/remove-deprecated-functions)

- This branch already has significant foundation work: new arch support, Kotlin bridge, TypeScript types
- The TurboModule spec (NativeRoktWidget.ts) on that branch already uses `selectPlacements` (not execute)
- The Rokt.tsx already uses `selectPlacements` with the new signature
- The iOS bridge (RNRoktWidget.mm) is already rewritten for new arch
- The Android bridge is already rewritten in Kotlin with new/old arch split
- The podspec on that branch still points to `~> 4.14.5` — needs bumping to `>= 5.0.0`
- The build.gradle on that branch points to `roktsdk:5.0.0` already
- **Strategy**: Cherry-pick or diff-apply the teammate's source files as foundation, then layer our additions on top (shoppable ads, event updates, final version bumps)

### iOS SDK 5.0.0 Migration (from ROKT/rokt-sdk-ios MIGRATING.md)

- `execute()` / `execute2step()` / `executeWithEvents()` → `selectPlacements()`
- `viewName` → `identifier` parameter rename
- `locationName` → `location` parameter rename
- `PlacementOptions` → `RoktPlacementOptions`
- `setLoggingEnabled(enable:)` removed → `setLogLevel(_:)` (.debug, .error, .none)
- `onInitComplete` callback removed from `initWith()` → use `globalEvents()` for `RoktEvent.InitComplete`
- Individual callbacks (onLoad, onUnLoad, etc.) → single `onEvent: { event in }` with RoktEvent pattern matching
- iOS minimum bumped from 12 to iOS 15
- SPM and CocoaPods moved to source distribution

### Android SDK 5.0.0 Migration (from ROKT/sdk-android-source MIGRATING.md)

- `execute()` / `execute2Step()` / `executeWithEvents()` → `selectPlacements()`
- `viewName` → `identifier` parameter rename
- `purchaseFinalized()`: `placementId` → `identifier`, `status` → `success`
- `events()`: `viewName` → `identifier`
- `RoktEvent.id` property → `identifier` on all event classes
- `RoktCallback`, `RoktInitCallback`, `RoktEventCallback`, `RoktEventHandler`, `RoktEventType`, `UnloadReasons` all REMOVED
- `setLoggingEnabled()` removed → use `Rokt.setLogLevel()`
- `execute2Step()` removed → use `selectPlacements()`
- `RoktInitCallback` removed from `init()` → use `globalEvents()` Flow for `RoktEvent.InitComplete`
- Individual callbacks → `RoktEventCollector` or `Flow<RoktEvent>` overload

### TurboModule Spec Changes (NativeRoktWidget.ts)

From teammate's branch, the spec already has:

```typescript
interface Spec extends TurboModule {
  initialize(roktTagId: string, appVersion: string): void;
  initializeWithFontFiles(
    roktTagId: string,
    appVersion: string,
    fontsMap: { [key: string]: string },
  ): void;
  selectPlacements(
    identifier: string,
    attributes: { [key: string]: string },
    placeholders: { [key: string]: number | null },
  ): void;
  selectPlacementsWithConfig(
    identifier: string,
    attributes: { [key: string]: string },
    placeholders: { [key: string]: number | null },
    roktConfig: RoktConfigType,
  ): void;
  purchaseFinalized(
    placementId: string,
    catalogItemId: string,
    success: boolean,
  ): void;
  setEnvironmentToStage(): void;
  setEnvironmentToProd(): void;
}
```

We need to ADD:

```typescript
  selectShoppableAds(identifier: string, attributes: { [key: string]: string }): void;
  selectShoppableAdsWithConfig(identifier: string, attributes: { [key: string]: string }, roktConfig: RoktConfigType): void;
```

And VERIFY removed methods are NOT present: no setLoggingEnabled, no execute, no execute2Step, no setFulfillmentAttributes, no setSessionId/getSessionId.

### Public API Changes (Rokt.tsx)

From teammate's branch, already has: `selectPlacements()`, `purchaseFinalized()`, `setEnvironmentToStage/Prod()`
Need to ADD: `selectShoppableAds()`
Need to VERIFY removed: no `execute()`, no `execute2Step()`, no `setLoggingEnabled()`, no `setFulfillmentAttributes()`, no `setSessionId/getSessionId()`

### iOS Native Bridge (RNRoktWidget.mm)

Teammate's branch already has the full rewrite with new arch support.
Need to:

- Update Rokt SDK import if needed for 5.0.0
- Verify selectPlacements uses onEvent callback (not individual callbacks)
- Add selectShoppableAds method (calls `[Rokt selectShoppableAds:identifier attributes:attributes config:config onEvent:^(RoktEvent *event) { ... }]`)
- Verify all deprecated methods removed

### Android Native Bridge (RNRoktWidgetModuleImpl.kt)

Teammate's branch already has Kotlin rewrite.
Need to:

- Verify selectPlacements uses onEvent/RoktEventCollector pattern
- Add selectShoppableAds method
- Verify all deprecated methods removed
- Verify parameter names match SDK 5.0 (identifier, not viewName)

### Event System

Both iOS and Android event managers need to handle new event types:

- CartItemInstantPurchaseInitiated (identifier, catalogItemId, cartItemId)
- CartItemInstantPurchase (catalogItemId, totalPrice, currency, quantity)
- CartItemInstantPurchaseFailure (error, catalogItemId)
- CartItemDevicePay (paymentProvider)
- InstantPurchaseDismissal (identifier)

The mParticle reference shows the unified onEvent pattern — event manager receives RoktEvent and emits appropriate JS events.

### SDK Dependency Versions

- iOS podspec: `s.dependency "Rokt-Widget", ">= 5.0.0"` (teammate has `~> 4.14.5`)
- iOS SPM: `minimumVersion: '5.0.0'`
- iOS platform: `>= 15.0` (teammate has `>= 10.0` — needs update)
- Android: `implementation ('com.rokt:roktsdk:5.0.0')` (teammate already has this)
- Package version: `5.0.0` (teammate has `4.11.4`)

### Claude's Discretion

- Exact merge strategy for teammate's branch (cherry-pick vs diff-apply vs manual)
- Whether to use setLogLevel as replacement for setLoggingEnabled or just remove
- RoktConfig builder pattern details for the RN bridge layer

</decisions>

<canonical_refs>

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Teammate's Branch (baseline to build upon)

- GitHub: https://github.com/ROKT/rokt-sdk-react-native/tree/feat/remove-deprecated-functions
- Key files to diff: NativeRoktWidget.ts, Rokt.tsx, RNRoktWidget.mm, RNRoktWidgetModuleImpl.kt, podspec, build.gradle, package.json

### Current Source (on our branch)

- `Rokt.Widget/src/NativeRoktWidget.ts` — TurboModule spec
- `Rokt.Widget/src/Rokt.tsx` — Public API (NOTE: already has selectShoppableAds from Wave 1 work)
- `Rokt.Widget/ios/RNRoktWidget.mm` — iOS bridge
- `Rokt.Widget/ios/RoktEventManager.m` — iOS event handling
- `Rokt.Widget/ios/RoktEventManager.h` — Event manager header
- `Rokt.Widget/android/src/main/java/com/rokt/reactnativesdk/RNRoktWidgetModuleImpl.kt` — Android impl
- `Rokt.Widget/android/src/newarch/java/com/rokt/reactnativesdk/RNRoktWidgetModule.kt` — New arch
- `Rokt.Widget/android/src/oldarch/java/com/rokt/reactnativesdk/RNRoktWidgetModule.kt` — Old arch
- `Rokt.Widget/rokt-react-native-sdk.podspec` — iOS dependency
- `Rokt.Widget/android/build.gradle` — Android dependency
- `Rokt.Widget/package.json` — Package version

### Migration Guides

- iOS: https://github.com/ROKT/rokt-sdk-ios/blob/main/MIGRATING.md
- Android: https://github.com/ROKT/sdk-android-source/blob/main/MIGRATING.md

### mParticle Reference (similar migration done)

- GitHub compare: mParticle/react-native-mparticle main...thomson-t/shoppable-ads-sdk9

</canonical_refs>

<specifics>
## Specific Ideas

### Wave 1 Work Already Done (on our branch)

Plan 01-01 already executed and committed:

- podspec bumped to `>= 5.0.0` with SPM `minimumVersion: '5.0.0'`, iOS platform `15.0`
- package.json version `5.0.0`
- NativeRoktWidget.ts has `selectShoppableAds` and `selectShoppableAdsWithConfig` added
- Rokt.tsx has `static selectShoppableAds()` method added
- BUT: This was additive only — the old execute/execute2Step methods were NOT removed
- AND: Android SDK version was NOT bumped (was intentionally left as no-op)

### What Still Needs to Happen

1. Remove old execute/execute2Step/executeWithConfig from TurboModule spec
2. Remove setLoggingEnabled, setFulfillmentAttributes, setSessionId/getSessionId from TurboModule spec
3. Rename any remaining viewName → identifier
4. Update iOS bridge to use onEvent callback pattern
5. Add selectShoppableAds to iOS bridge
6. Update Android bridge: bump SDK, use selectPlacements, add selectShoppableAds
7. Update both event managers for new event types
8. Ensure both old/new arch wrappers are consistent

### Build Verification (MANDATORY for every phase)

Every phase MUST end with a build verification task that:

1. Builds the Rokt.Widget package (`cd Rokt.Widget && npm run build`)
2. Installs the built package in RoktSampleApp (`cd RoktSampleApp && npm install`)
3. Installs the built package in ExpoTestApp (`cd ExpoTestApp && npm install`)
4. Builds RoktSampleApp iOS (`cd RoktSampleApp/ios && pod install && xcodebuild build ...`)
5. Builds RoktSampleApp Android (`cd RoktSampleApp/android && ./gradlew assembleDebug`)
6. Builds ExpoTestApp iOS (`cd ExpoTestApp && npx expo prebuild --platform ios && cd ios && pod install && xcodebuild build ...`)
7. Builds ExpoTestApp Android (`cd ExpoTestApp && npx expo prebuild --platform android && cd android && ./gradlew assembleDebug`)

This ensures the SDK changes don't break consumers. Build failures block the phase.

</specifics>

<deferred>
## Deferred Ideas

- Example app API updates and shoppable ads demo (Phase 2)
- README + migration guide (Phase 3)

</deferred>

---

_Phase: 01-sdk-bridge-events_
_Context gathered: 2026-04-14 after scope expansion_
