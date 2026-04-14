# Requirements: Rokt RN SDK Shoppable Ads

**Defined:** 2026-04-14
**Core Value:** Partners using React Native can trigger Shoppable Ads placements and handle purchase events

## v1 Requirements

### SDK Dependencies

- [ ] **SDK-01**: iOS SDK dependency updated to Rokt-Widget >= 5.0.0
- [ ] **SDK-02**: Android SDK dependency unchanged (4.14.1)
- [ ] **SDK-03**: Package version bumped appropriately

### Bridge API

- [ ] **API-01**: `registerPaymentExtension` method exposed in TurboModule spec (NativeRoktWidget.ts)
- [ ] **API-02**: `registerPaymentExtension` implemented in iOS native bridge (RNRoktWidget.mm)
- [ ] **API-03**: `registerPaymentExtension` added as no-op in Android native bridge (RNRoktWidgetModuleImpl.kt)
- [ ] **API-04**: `registerPaymentExtension` exposed in public Rokt.tsx API
- [ ] **API-05**: Both old and new RN architecture paths work for new API

### Events

- [ ] **EVT-01**: CartItemInstantPurchaseInitiated event type handled and emitted
- [ ] **EVT-02**: CartItemInstantPurchase event type handled and emitted
- [ ] **EVT-03**: CartItemInstantPurchaseFailure event type handled and emitted
- [ ] **EVT-04**: InstantPurchaseDismissal event type handled and emitted
- [ ] **EVT-05**: CartItemDevicePay event type with paymentProvider context handled

### Example Apps

- [ ] **APP-01**: RoktSampleApp demonstrates shoppable ads flow with payment extension registration
- [ ] **APP-02**: ExpoTestApp demonstrates shoppable ads flow with payment extension registration
- [ ] **APP-03**: Extension library (RoktPaymentExtension) added to iOS sample app targets
- [ ] **APP-04**: registerPaymentExtension called in native AppDelegate code

## v2 Requirements

### Android

- **AND-01**: Full Android Shoppable Ads implementation (separate bet)

## Out of Scope

| Feature                    | Reason                                       |
| -------------------------- | -------------------------------------------- |
| Android Shoppable Ads      | Separate bet — no-op stubs only              |
| Google Pay                 | Apple Pay only for this cycle                |
| Web SDK support            | Different platform                           |
| New Shoppable Ads features | Only exposing what iOS SDK 5.0.0 already has |

## Traceability

| Requirement | Phase   | Status  |
| ----------- | ------- | ------- |
| SDK-01      | Phase 1 | Pending |
| SDK-02      | Phase 1 | Pending |
| SDK-03      | Phase 1 | Pending |
| API-01      | Phase 1 | Pending |
| API-02      | Phase 1 | Pending |
| API-03      | Phase 1 | Pending |
| API-04      | Phase 1 | Pending |
| API-05      | Phase 1 | Pending |
| EVT-01      | Phase 1 | Pending |
| EVT-02      | Phase 1 | Pending |
| EVT-03      | Phase 1 | Pending |
| EVT-04      | Phase 1 | Pending |
| EVT-05      | Phase 1 | Pending |
| APP-01      | Phase 2 | Pending |
| APP-02      | Phase 2 | Pending |
| APP-03      | Phase 2 | Pending |
| APP-04      | Phase 2 | Pending |

**Coverage:**

- v1 requirements: 17 total
- Mapped to phases: 17
- Unmapped: 0 ✓

---

_Requirements defined: 2026-04-14_
_Last updated: 2026-04-14 after initial definition_
