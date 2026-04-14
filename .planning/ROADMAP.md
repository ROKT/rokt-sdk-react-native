# Roadmap: Rokt RN SDK Shoppable Ads

**Created:** 2026-04-14
**Milestone:** v1.0 — Shoppable Ads RN Support
**Phases:** 2
**Requirements:** 17

## Phase Overview

| #   | Phase               | Goal                                                                                                         | Requirements                                                                                           | Success Criteria |
| --- | ------------------- | ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------ | ---------------- |
| 1   | SDK Bridge & Events | Update iOS SDK to 5.0.0, add registerPaymentExtension API to bridge, add shoppable ads events, Android no-op | SDK-01, SDK-02, SDK-03, API-01, API-02, API-03, API-04, API-05, EVT-01, EVT-02, EVT-03, EVT-04, EVT-05 | 5                |
| 2   | Example Apps        | Demonstrate shoppable ads in RoktSampleApp and ExpoTestApp with payment extension                            | APP-01, APP-02, APP-03, APP-04                                                                         | 4                |

---

## Phase 1: SDK Bridge & Events

**Goal:** Update iOS SDK dependency to 5.0.0, expose registerPaymentExtension through the RN bridge (iOS real, Android no-op), and handle new shoppable ads event types.

**Requirements:** SDK-01, SDK-02, SDK-03, API-01, API-02, API-03, API-04, API-05, EVT-01, EVT-02, EVT-03, EVT-04, EVT-05

**Success Criteria:**

1. iOS podspec dependency is Rokt-Widget >= 5.0.0
2. `registerPaymentExtension` callable from React Native JS and forwards to native iOS SDK
3. Android `registerPaymentExtension` exists as no-op (does not crash)
4. New shoppable ads events (CartItemInstantPurchaseInitiated, CartItemInstantPurchase, CartItemInstantPurchaseFailure, InstantPurchaseDismissal, CartItemDevicePay) are emitted through RoktEvents
5. Both old and new RN architecture paths compile and work

**Depends on:** None

---

## Phase 2: Example Apps

**Goal:** Add working shoppable ads demonstrations to both the standard RoktSampleApp and ExpoTestApp, including native payment extension registration.

**Requirements:** APP-01, APP-02, APP-03, APP-04

**Success Criteria:**

1. RoktSampleApp demonstrates full shoppable ads flow
2. ExpoTestApp demonstrates full shoppable ads flow
3. RoktPaymentExtension library added to iOS app targets via SPM/CocoaPods
4. registerPaymentExtension called in AppDelegate native code

**Depends on:** Phase 1

---

_Roadmap created: 2026-04-14_
_Last updated: 2026-04-14 after initial creation_
