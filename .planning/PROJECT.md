# Rokt React Native SDK — Shoppable Ads Support

## What This Is

Add Shoppable Ads (Post-Purchase Upsell) API support to the Rokt React Native SDK. This involves updating the iOS SDK dependency to 5.0.0, exposing the `registerPaymentExtension` API through the React Native bridge, adding new shoppable ads event types, and providing working examples in both the standard React Native sample app and Expo app. The Android path will be a no-op stub for now.

## Core Value

Partners using React Native can trigger Shoppable Ads placements, register payment extensions, and handle purchase events — achieving feature parity with the native iOS SDK's shoppable ads capabilities.

## Requirements

### Validated

- ✓ Core SDK initialization (initialize/initializeWithFontFiles) — existing
- ✓ Placement execution (execute/execute2Step) — existing
- ✓ purchaseFinalized API — existing
- ✓ Event system (RoktEvents, RoktCallback) — existing
- ✓ Both old and new RN architecture support — existing
- ✓ Embedded view component — existing
- ✓ Session management — existing

### Active

- [ ] Update Rokt iOS SDK dependency to 5.0.0
- [ ] Add `registerPaymentExtension` API to RN bridge (iOS implementation, Android no-op)
- [ ] Add new shoppable ads event types (CartItemInstantPurchaseInitiated, CartItemInstantPurchase, CartItemInstantPurchaseFailure, InstantPurchaseDismissal, CartItemDevicePay)
- [ ] Demonstrate shoppable ads flow in RoktSampleApp
- [ ] Demonstrate shoppable ads flow in ExpoTestApp
- [ ] Payment extension registration in native iOS app code (AppDelegate)
- [ ] Extension library integration in iOS sample apps

### Out of Scope

- Android Shoppable Ads implementation — separate bet, Android is no-op stub only
- Web SDK Shoppable Ads support
- New features beyond what exists on iOS SDK 5.0.0 feature branches
- Google Pay support (Apple Pay only)

## Context

- Shoppable Ads is already fully implemented in the native iOS SDK (sdk-ios-source) on feature branches
- The Rokt iOS SDK 5.0.0 includes PaymentExtension protocol, PaymentOrchestrator, and cart APIs
- Similar changes were done in the mParticle React Native SDK (https://github.com/mParticle/react-native-mparticle/compare/thomson-t/shoppable-ads-sdk9)
- Key difference: mParticle joint SDK has different init and registerPaymentExtension patterns vs direct Rokt SDK
- Current iOS SDK dependency is >= 4.15, < 5 — needs bump to >= 5.0.0
- Current Android SDK is 4.14.1 — stays unchanged
- Integration guide: https://docs.rokt.com/developers/integration-guides/shoppable-ads/sdk-integration-guides/ios-sdk-integration/?sdkPath=direct

## Constraints

- **iOS SDK**: Must use Rokt-Widget 5.0.0 — breaking major version change
- **Android**: No-op stubs only — real implementation deferred
- **Architecture**: Must support both old (Bridge) and new (TurboModule/Fabric) React Native architectures
- **Extension pattern**: PaymentExtension must be registered in native app code (AppDelegate), not from JS

## Key Decisions

| Decision                         | Rationale                                                                | Outcome   |
| -------------------------------- | ------------------------------------------------------------------------ | --------- |
| Android API as no-op             | Android Shoppable Ads is a separate bet                                  | — Pending |
| Payment extension in native code | PaymentExtension protocol requires native Apple Pay / Stripe integration | — Pending |
| iOS SDK 5.0.0 major version bump | Shoppable Ads APIs only available in 5.x                                 | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):

1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):

1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---

_Last updated: 2026-04-14 after initialization_
