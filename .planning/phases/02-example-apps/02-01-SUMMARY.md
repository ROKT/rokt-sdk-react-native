---
phase: 02-example-apps
plan: "01"
subsystem: example-apps
tags: [react-native, sample-app, expo, shoppable-ads, v5.0.0]
dependency_graph:
  requires:
    [
      01-sdk-bridge-events/01-01,
      01-sdk-bridge-events/01-02,
      01-sdk-bridge-events/01-03,
    ]
  provides: [updated-sample-apps-v5]
  affects: [RoktSampleApp, ExpoTestApp]
tech_stack:
  added: [RoktPaymentExtension, RoktStripePaymentExtension]
  patterns:
    [
      selectPlacements,
      selectShoppableAds,
      RoktEvents listener,
      payment extension registration,
    ]
key_files:
  created: []
  modified:
    - RoktSampleApp/App.tsx
    - RoktSampleApp/utils/rokt-constants.js
    - RoktSampleApp/ios/RoktSampleApp/AppDelegate.swift
    - RoktSampleApp/ios/Podfile
    - ExpoTestApp/App.tsx
decisions:
  - "Removed execute2Step and executeEncrypted flows entirely — no equivalent in v5.0.0"
  - "Shoppable Ads button added inline in button row (RoktSampleApp) and stacked column (ExpoTestApp)"
  - "AppDelegate imports Rokt_Widget and RoktPaymentExtension, registers RoktStripePaymentExtension with placeholder test key"
  - "FULLFILLMENT_ATTRIBUTES removed from rokt-constants.js — setFulfillmentAttributes no longer exists"
  - "ExpoTestApp variable renamed from viewName/DEFAULT_VIEW_NAME to identifier/DEFAULT_IDENTIFIER for v5.0.0 semantics"
metrics:
  duration: ~15 minutes
  completed: 2026-04-14
  tasks_completed: 2
  files_changed: 5
---

# Phase 02 Plan 01: Update Example Apps for v5.0.0 API Summary

Both sample apps migrated from deprecated v4.x API to v5.0.0 surface: `selectPlacements` replaces `execute`, `selectShoppableAds` added with full event handling, payment extension registered in native iOS AppDelegate.

## Tasks Completed

| Task | Name                                            | Commit  | Files                                                  |
| ---- | ----------------------------------------------- | ------- | ------------------------------------------------------ |
| 1    | Update RoktSampleApp for v5.0.0 + shoppable ads | 25e5c83 | App.tsx, rokt-constants.js, AppDelegate.swift, Podfile |
| 2    | Update ExpoTestApp for v5.0.0 + shoppable ads   | f73386b | ExpoTestApp/App.tsx                                    |

## What Was Built

### RoktSampleApp (App.tsx)

- Replaced `Rokt.execute()` with `Rokt.selectPlacements(identifier, attributes, placeholders)`
- Removed `execute2Step` method and `twoStepEnabled` state
- Removed `executeEncrypted` method and `encryptEnabled` state
- Removed `subscription` and `callBackSubscription` (FirstPositiveResponse, RoktCallback events)
- Added `onShoppableAdsHandler` calling `Rokt.selectShoppableAds(viewName, attributes)`
- Added "Shoppable Ads" button in button row
- Added shoppable event logging in RoktEvents listener: `CartItemInstantPurchaseInitiated`, `CartItemInstantPurchaseFailure`, `CartItemDevicePay`, `InstantPurchaseDismissal`
- Removed crypto-js/sha256, buffer, node-forge imports (no longer needed)
- Removed `setLoggingEnabled` call from `onInitHandler`

### RoktSampleApp (rokt-constants.js)

- `DEFAULT_VIEW_NAME` changed from `'testTwoEmbedded'` to `'MSDKEmbeddedLayout'`
- Removed `FULLFILLMENT_ATTRIBUTES` export

### RoktSampleApp (AppDelegate.swift)

- Added `import Rokt_Widget` and `import RoktPaymentExtension`
- Added `RoktStripePaymentExtension` registration after `factory.startReactNative`
- Uses placeholder Stripe test key `pk_test_placeholder`

### RoktSampleApp (Podfile)

- Added `pod 'RoktPaymentExtension'` inside the target block

### ExpoTestApp (App.tsx)

- Replaced `Rokt.execute()` with `Rokt.selectPlacements(identifier, attributes, placeholders)`
- Removed `Rokt.setLoggingEnabled(true)` from `handleInitialize`
- Added `handleShoppableAds` calling `Rokt.selectShoppableAds(identifier, attributes)`
- Added "Shoppable Ads" button (orange, stacked vertically)
- Added shoppable event handling in RoktEvents listener (CartItemInstantPurchase calls purchaseFinalized, plus new v5.0.0 shoppable events)
- Renamed `viewName`/`DEFAULT_VIEW_NAME` to `identifier`/`DEFAULT_IDENTIFIER`
- Updated subtitle to "Testing v5.0.0 SDK Integration"
- Switched buttonContainer to `flexDirection: "column"` for 3-button layout

## Deviations from Plan

None - plan executed exactly as written.

The teammate's `feat/remove-deprecated-functions` branch baseline was used for RoktSampleApp. The branch had already removed `subscription`/`callBackSubscription` and `setLoggingEnabled`, and changed the main execute path to `selectPlacements`. Additional changes (execute2Step removal, shoppable ads, AppDelegate, Podfile) were applied on top.

## Known Stubs

None. All API calls are wired to real SDK methods. The Stripe key `pk_test_placeholder` is intentional per the threat model (T-02-01 — sample app uses placeholder, not a real secret).

## Threat Flags

None. All new surface was pre-assessed in the plan's threat model:

- T-02-01: AppDelegate stripe key accepted (placeholder test key)
- T-02-02: Sample app fake attributes accepted
- T-02-03: Event handlers console-only accepted

## Self-Check: PASSED

- FOUND: RoktSampleApp/App.tsx
- FOUND: RoktSampleApp/utils/rokt-constants.js
- FOUND: RoktSampleApp/ios/RoktSampleApp/AppDelegate.swift
- FOUND: RoktSampleApp/ios/Podfile
- FOUND: ExpoTestApp/App.tsx
- FOUND: .planning/phases/02-example-apps/02-01-SUMMARY.md
- FOUND commit: 25e5c83 (Task 1)
- FOUND commit: f73386b (Task 2)
