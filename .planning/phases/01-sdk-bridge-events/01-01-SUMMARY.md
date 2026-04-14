---
phase: 01-sdk-bridge-events
plan: "01"
subsystem: sdk-bridge
tags: [android, typescript, sdk-migration, v5.0.0, shoppable-ads]
dependency_graph:
  requires: []
  provides: [android-sdk-5.0.0, turbomodule-spec-v5, public-api-v5]
  affects: [Rokt.Widget/src, Rokt.Widget/android]
tech_stack:
  added: []
  patterns: [unified-flow-event-collection, turbomodule-spec]
key_files:
  created: []
  modified:
    - Rokt.Widget/android/build.gradle
    - Rokt.Widget/android/src/main/java/com/rokt/reactnativesdk/RNRoktWidgetModuleImpl.kt
    - Rokt.Widget/src/NativeRoktWidget.ts
    - Rokt.Widget/src/Rokt.tsx
decisions:
  - Applied teammate baseline (feat/remove-deprecated-functions) for Android and TypeScript layers, then layered shoppable ads on top
  - Used event.identifier for new shoppable events (CartItemInstantPurchaseInitiated, CartItemInstantPurchaseFailure, CartItemDevicePay, InstantPurchaseDismissal) consistent with SDK 5.0.0 naming
  - logDebug gated on debug=false by default per T-01-02 threat mitigation
metrics:
  duration: "~15 minutes"
  completed: "2026-04-14"
  tasks_completed: 2
  files_modified: 4
---

# Phase 01 Plan 01: Rewrite TypeScript Layer and Android Impl for SDK 5.0.0 Summary

**One-liner:** Migrated TurboModule spec, public API, and Android impl to Rokt SDK 5.0.0 — renamed execute→selectPlacements, removed all deprecated methods, added shoppable ads events.

## Tasks Completed

| Task | Name                                                        | Commit  | Files                                                       |
| ---- | ----------------------------------------------------------- | ------- | ----------------------------------------------------------- |
| 1    | Rewrite Android shared impl and bump SDK to 5.0.0           | 13df8ea | Rokt.Widget/android/build.gradle, RNRoktWidgetModuleImpl.kt |
| 2    | Rewrite TurboModule spec and Rokt.tsx public API for v5.0.0 | 5e3205b | NativeRoktWidget.ts, Rokt.tsx                               |

## What Was Built

### Android (Task 1)

- `build.gradle`: bumped `roktsdk` from `4.14.1` to `5.0.0`
- `RNRoktWidgetModuleImpl.kt`: replaced with teammate baseline from `feat/remove-deprecated-functions`, then added new shoppable ads event types:
  - Removed: `setLoggingEnabled`, `setFulfillmentAttributes`, `setSessionId`, `getSessionId`, `createRoktCallback`
  - Removed: `roktEventHandler`, `fulfillmentAttributesCallback`, `listeners` map fields
  - Kept: unified flow-based `startRoktEventListener` with `Rokt.globalEvents()`
  - Added 4 new shoppable event handlers: `CartItemInstantPurchaseInitiated`, `CartItemInstantPurchaseFailure`, `CartItemDevicePay`, `InstantPurchaseDismissal`

### TypeScript (Task 2)

- `NativeRoktWidget.ts`: clean v5.0.0 TurboModule spec with exactly 9 methods:
  - `initialize`, `initializeWithFontFiles`, `selectPlacements`, `selectPlacementsWithConfig`, `selectShoppableAds`, `selectShoppableAdsWithConfig`, `purchaseFinalized`, `setEnvironmentToStage`, `setEnvironmentToProd`
  - Removed: `execute`, `executeWithConfig`, `execute2Step`, `execute2StepWithConfig`, `setLoggingEnabled`, `setFulfillmentAttributes`, `setSessionId`, `getSessionId`
- `Rokt.tsx`: public API with exactly 6 static methods:
  - `initialize`, `selectPlacements`, `selectShoppableAds`, `purchaseFinalized`, `setEnvironmentToStage`, `setEnvironmentToProd`
  - `selectShoppableAds` JSDoc preserved from prior Wave 1 work
  - `identifier` parameter naming used throughout (no `viewName`)

## Verification Results

- TypeScript compilation: `npx tsc --noEmit` passes with zero errors
- NativeRoktWidget.ts: 9 methods confirmed
- Rokt.tsx: 6 public static methods confirmed
- Android build.gradle: `roktsdk:5.0.0` confirmed
- RNRoktWidgetModuleImpl.kt: no deprecated method references
- All 4 new shoppable event types present in Android event listener
- No `viewName` parameter in TypeScript files

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None — all methods are wired through to native calls.

## Threat Flags

None — T-01-02 verified: `logDebug` is gated on `debug = false` by default; new shoppable event params (catalogItemId, cartItemId, error, paymentProvider) contain no sensitive PII.

## Self-Check: PASSED

- All 4 modified files exist on disk
- Commits 13df8ea and 5e3205b verified in git log
- TypeScript compilation passes (zero errors)
- All acceptance criteria verified via grep checks
