# Rokt React Native SDK — v5.0.0 Migration & Shoppable Ads

## What This Is

Migrate the Rokt React Native SDK to v5.0.0 of both iOS and Android native SDKs. This is a breaking change that renames core APIs (execute → selectPlacements), removes deprecated methods, adds Shoppable Ads support (selectShoppableAds, registerPaymentExtension), updates the event system to a unified onEvent pattern, and provides documentation including a migration guide. A teammate has foundation work on `feat/remove-deprecated-functions` branch to build upon.

## Core Value

React Native SDK achieves API parity with native iOS/Android SDK 5.0.0, including Shoppable Ads and the modernized API surface.

## Requirements

### Validated

- ✓ Core SDK initialization (initialize/initializeWithFontFiles) — existing
- ✓ Event system (RoktEvents, RoktCallback) — existing
- ✓ Both old and new RN architecture support — existing
- ✓ Embedded view component — existing

### Active

- [ ] Update iOS SDK dependency to Rokt-Widget 5.0.0
- [ ] Update Android SDK dependency to roktsdk 5.0.0
- [ ] Rename execute/execute2Step/executeWithConfig → selectPlacements/selectPlacementsWithConfig
- [ ] Rename viewName → identifier across all APIs
- [ ] Remove deprecated APIs: setLoggingEnabled, execute2Step, setFulfillmentAttributes, setSessionId/getSessionId
- [ ] Update callback architecture to unified onEvent pattern
- [ ] Add selectShoppableAds API (iOS real, Android real)
- [ ] Add purchaseFinalized with renamed params (placementId → identifier)
- [ ] Update RoktConfig to use builder pattern (SDK 5.0 style)
- [ ] Demonstrate in RoktSampleApp and ExpoTestApp
- [ ] Payment extension registration in native iOS app code
- [ ] Update README.md documentation
- [ ] Create MIGRATING.md migration guide
- [ ] Cherry-pick/leverage teammate's `feat/remove-deprecated-functions` branch work

### Out of Scope

- Google Pay support (Apple Pay only)
- Web SDK Shoppable Ads support
- New features beyond what's in SDK 5.0.0

## Context

- iOS migration guide: https://github.com/ROKT/rokt-sdk-ios/blob/main/MIGRATING.md
- Android migration guide: https://github.com/ROKT/sdk-android-source/blob/main/MIGRATING.md
- Teammate's branch: https://github.com/ROKT/rokt-sdk-react-native/tree/feat/remove-deprecated-functions
- mParticle reference: https://github.com/mParticle/react-native-mparticle/compare/thomson-t/shoppable-ads-sdk9
- Integration guide: https://docs.rokt.com/developers/integration-guides/shoppable-ads/sdk-integration-guides/ios-sdk-integration/?sdkPath=direct

## Constraints

- **Breaking change**: This is a major version bump — all API renames are intentional breaking changes
- **Architecture**: Must support both old (Bridge) and new (TurboModule/Fabric) React Native architectures
- **Extension pattern**: PaymentExtension must be registered in native app code (AppDelegate), not from JS
- **Teammate's work**: Leverage `feat/remove-deprecated-functions` branch where possible

## Key Decisions

| Decision                         | Rationale                                      | Outcome   |
| -------------------------------- | ---------------------------------------------- | --------- |
| Both iOS + Android SDK 5.0.0     | Full parity with native SDKs                   | — Pending |
| Breaking API renames             | Align with native SDK 5.0 naming               | — Pending |
| Payment extension in native code | Requires native Apple Pay / Stripe integration | — Pending |
| Leverage teammate branch         | Foundation work already done                   | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

---

_Last updated: 2026-04-14 after scope expansion_
