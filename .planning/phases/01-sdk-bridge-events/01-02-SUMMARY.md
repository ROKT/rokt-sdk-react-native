---
phase: 01-sdk-bridge-events
plan: "02"
subsystem: ios-bridge
tags: [ios, objc, sdk-migration, v5.0.0, shoppable-ads, event-manager]
dependency_graph:
  requires: [android-sdk-5.0.0, turbomodule-spec-v5, public-api-v5]
  provides: [ios-bridge-v5.0.0, ios-event-manager-v5.0.0]
  affects: [Rokt.Widget/ios]
tech_stack:
  added: []
  patterns: [unified-onEvent-callback, identifier-based-api, shoppable-ads-events]
key_files:
  created: []
  modified:
    - Rokt.Widget/ios/RNRoktWidget.mm
    - Rokt.Widget/ios/RNRoktWidget.h
    - Rokt.Widget/ios/RoktEventManager.m
    - Rokt.Widget/ios/RoktEventManager.h
decisions:
  - Applied teammate baseline (feat/remove-deprecated-functions) for iOS bridge and event manager, then layered shoppable ads on top
  - Payload key stays "viewName" for backward JS compatibility; ObjC param renamed to identifier
  - selectShoppableAds uses onEvent:nil (delegates to eventsWithIdentifier subscription, consistent with selectPlacements pattern)
  - EmbeddedSizeChanged handler calls onWidgetHeightChanges inline (from teammate baseline)
metrics:
  duration: "~10 minutes"
  completed: "2026-04-14"
  tasks_completed: 2
  files_modified: 4
---

# Phase 01 Plan 02: Rewrite iOS Bridge and Event Manager for SDK 5.0.0 Summary

**One-liner:** Migrated iOS native bridge and event manager to Rokt SDK 5.0.0 — renamed execute→selectPlacements, removed all deprecated methods, added selectShoppableAds, and wired up four new shoppable ads event types.

## Tasks Completed

| Task | Name                                                              | Commit  | Files                                                    |
| ---- | ----------------------------------------------------------------- | ------- | -------------------------------------------------------- |
| 1    | Rewrite iOS bridge (RNRoktWidget.mm) for v5.0.0                   | af9e8d3 | Rokt.Widget/ios/RNRoktWidget.mm, RNRoktWidget.h          |
| 2    | Rewrite iOS event manager for v5.0.0 with shoppable ads events    | 4f8e964 | Rokt.Widget/ios/RoktEventManager.m, RoktEventManager.h  |

## What Was Built

### iOS Bridge (Task 1)

- `RNRoktWidget.mm`: replaced with teammate baseline from `feat/remove-deprecated-functions`, then added shoppable ads methods:
  - Removed: `execute`, `executeWithConfig`, `execute2Step`, `execute2StepWithConfig` (all arch variants)
  - Removed: `setLoggingEnabled`, `setFulfillmentAttributes`, `setSessionId`, `getSessionId`
  - Removed: `roktEventHandler` property, `executeRoktWithViewName`, `executeRokt2StepWithViewName` private helpers
  - Renamed: `subscribeViewEvents:` now uses `Rokt eventsWithIdentifier:` (not `eventsWithViewName:`)
  - Renamed: `subscribeGlobalEvents` now calls `onRoktEvents:identifier:` (not `onRoktEvents:viewName:`)
  - Updated: `purchaseFinalized` now calls `purchaseFinalizedWithIdentifier:` (not `purchaseFinalizedWithPlacementId:`)
  - Added: `selectPlacements` with `selectPlacementsWithIdentifier:` and unified `onEvent:nil`
  - Added: `selectPlacementsWithConfig` (both new arch and old arch variants)
  - Added: `selectShoppableAds` calling `selectShoppableAdsWithIdentifier:` with `onEvent:nil`
  - Added: `selectShoppableAdsWithConfig` (both new arch and old arch variants)
- `RNRoktWidget.h`: no changes needed — header was already clean (no deprecated declarations)

### iOS Event Manager (Task 2)

- `RoktEventManager.h`: replaced with teammate baseline:
  - Removed: `firstPositiveEngagement` property
  - Removed: `onFirstPositiveResponse` method declaration
  - Removed: `onRoktCallbackReceived:` method declaration
  - Changed: `onRoktEvents:viewName:` → `onRoktEvents:identifier:`
- `RoktEventManager.m`: replaced with teammate baseline, then added new shoppable ads events:
  - `supportedEvents` now returns only `@[@"WidgetHeightChanges", @"RoktEvents"]` (removed `FirstPositiveResponse`, `RoktCallback`)
  - Removed: `onFirstPositiveResponse` method
  - Removed: `onRoktCallbackReceived:` method
  - Added: `EmbeddedSizeChanged` handler (calls `onWidgetHeightChanges` inline from within `onRoktEvents`)
  - Added: `CartItemInstantPurchaseInitiated` handler (placementId, catalogItemId, cartItemId)
  - Added: `CartItemInstantPurchaseFailure` handler (placementId, catalogItemId, error)
  - Added: `CartItemDevicePay` handler (placementId, paymentProvider)
  - Added: `InstantPurchaseDismissal` handler (placementId)
  - Added: `error` and `paymentProvider` fields to event payload population
  - Payload key `"viewName"` preserved for backward JS compatibility; ObjC param is `identifier`

## Verification Results

- RNRoktWidget.mm: `selectPlacements` present
- RNRoktWidget.mm: `selectShoppableAds` and `selectShoppableAdsWithIdentifier` present
- RNRoktWidget.mm: no `executeWithViewName`, `execute2step`, `execute2Step`
- RNRoktWidget.mm: no `setLoggingEnabled`, `setFulfillmentAttributes`, `setSessionId`, `getSessionId`
- RNRoktWidget.mm: no `roktEventHandler`, no individual callbacks (`onLoad`, `onUnLoad`, `onShouldShowLoadingIndicator`)
- RNRoktWidget.mm: `purchaseFinalizedWithIdentifier` and `eventsWithIdentifier` present
- RoktEventManager.m: all 4 new shoppable event types present
- RoktEventManager.m: `EmbeddedSizeChanged` present
- RoktEventManager.h: `onRoktEvents:identifier:` signature confirmed
- RoktEventManager.m: no `onFirstPositiveResponse`, `onRoktCallbackReceived`, `FirstPositiveResponse`
- RoktEventManager.h: no `firstPositiveEngagement` property

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None — all methods are wired through to native Rokt SDK calls.

## Threat Flags

None — T-01-03 verified: nil checks added before all SDK calls in new methods (`selectShoppableAds`, `selectShoppableAdsWithConfig`). T-01-04 verified: event data comes from Rokt SDK, no user secrets exposed in new shoppable ads event payloads.

## Self-Check: PASSED

- `Rokt.Widget/ios/RNRoktWidget.mm` exists with all acceptance criteria verified
- `Rokt.Widget/ios/RoktEventManager.m` exists with all 4 new event types
- `Rokt.Widget/ios/RoktEventManager.h` exists with identifier-based signature
- Commits af9e8d3 and 4f8e964 verified in git log
- All grep verification checks passed (11/11 for Task 1, 10/10 for Task 2)
