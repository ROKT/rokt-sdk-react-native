---
phase: 01-sdk-bridge-events
plan: 01
subsystem: sdk-bridge
tags: [ios, turbomodule, typescript, versioning]
dependency_graph:
  requires: []
  provides: [ios-sdk-5.0.0-dep, selectShoppableAds-ts-api]
  affects: [02-ios-bridge, 03-android-bridge]
tech_stack:
  added: []
  patterns: [TurboModule spec extension, public static API delegation]
key_files:
  created: []
  modified:
    - Rokt.Widget/rokt-react-native-sdk.podspec
    - Rokt.Widget/package.json
    - Rokt.Widget/src/NativeRoktWidget.ts
    - Rokt.Widget/src/Rokt.tsx
decisions:
  - iOS platform minimum raised to 15.0 to match Rokt-Widget 5.0.0 requirements
  - SPM and CocoaPods both updated to 5.0.0 for consistency
  - selectShoppableAdsWithConfig added alongside selectShoppableAds following existing WithConfig pattern
metrics:
  duration: ~10 minutes
  completed: 2026-04-14T18:24:00Z
  tasks_completed: 2
  tasks_total: 2
  files_modified: 4
requirements:
  - SDK-01
  - SDK-02
  - SDK-03
  - API-01
  - API-04
---

# Phase 01 Plan 01: SDK Dependency Update and TypeScript API Contract Summary

## One-liner

Updated iOS SDK dependency to Rokt-Widget >= 5.0.0 (CocoaPods + SPM) and added selectShoppableAds/selectShoppableAdsWithConfig to the TurboModule Spec and public Rokt class.

## What Was Built

### Task 1: SDK Dependency Versions (commit `90b212f`)

Updated `Rokt.Widget/rokt-react-native-sdk.podspec`:

- CocoaPods dependency changed from `>= 4.15, < 5` to `>= 5.0.0`
- SPM `minimumVersion` changed from `4.15.0` to `5.0.0`
- iOS platform minimum raised from `10.0` to `15.0` (required by SDK 5.0.0)

Updated `Rokt.Widget/package.json`:

- Package version bumped from `4.12.2` to `5.0.0` (major bump matching iOS SDK major version)

Android `build.gradle` left unchanged — `roktsdk:4.14.1` remains.

### Task 2: selectShoppableAds TypeScript API (commit `e36e972`)

Added to `Rokt.Widget/src/NativeRoktWidget.ts` Spec interface:

- `selectShoppableAds(identifier, attributes): void`
- `selectShoppableAdsWithConfig(identifier, attributes, roktConfig): void`

Added to `Rokt.Widget/src/Rokt.tsx` Rokt class:

- `public static selectShoppableAds(identifier, attributes, roktConfig?)` with JSDoc
- Delegates to native `selectShoppableAds` or `selectShoppableAdsWithConfig` based on config presence
- Follows identical pattern to existing `execute` / `executeWithConfig` delegation

`index.tsx` unchanged — `Rokt` class is already exported, no new exports needed.

TypeScript compiles without errors.

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None — no UI rendering or data source wiring in this plan. The `selectShoppableAds` native methods declared in the TurboModule Spec will be implemented by Plan 02 (iOS) and Plan 03 (Android).

## Threat Flags

None — no new network endpoints, auth paths, or schema changes introduced. The `selectShoppableAds` method follows the same trust boundary pattern as the existing `execute` methods (JS → Native bridge, string key-value attributes).

## Self-Check: PASSED

| Item                                                   | Status |
| ------------------------------------------------------ | ------ |
| Rokt.Widget/rokt-react-native-sdk.podspec              | FOUND  |
| Rokt.Widget/package.json                               | FOUND  |
| Rokt.Widget/src/NativeRoktWidget.ts                    | FOUND  |
| Rokt.Widget/src/Rokt.tsx                               | FOUND  |
| .planning/phases/01-sdk-bridge-events/01-01-SUMMARY.md | FOUND  |
| Commit 90b212f (Task 1)                                | FOUND  |
| Commit e36e972 (Task 2)                                | FOUND  |
