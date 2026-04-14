# Requirements: Rokt RN SDK v5.0.0 Migration & Shoppable Ads

**Defined:** 2026-04-14
**Core Value:** React Native SDK achieves API parity with native iOS/Android SDK 5.0.0

## v1 Requirements

### SDK Dependencies

- [ ] **SDK-01**: iOS SDK dependency updated to Rokt-Widget >= 5.0.0 (podspec + SPM)
- [ ] **SDK-02**: Android SDK dependency updated to roktsdk 5.0.0
- [ ] **SDK-03**: Package version bumped to 5.0.0
- [ ] **SDK-04**: iOS platform minimum raised to 15.0

### API Renames

- [ ] **REN-01**: execute/executeWithConfig renamed to selectPlacements/selectPlacementsWithConfig in TurboModule spec
- [ ] **REN-02**: execute/executeWithConfig renamed to selectPlacements/selectPlacementsWithConfig in iOS bridge
- [ ] **REN-03**: execute/executeWithConfig renamed to selectPlacements/selectPlacementsWithConfig in Android bridge
- [ ] **REN-04**: execute/executeWithConfig renamed to selectPlacements/selectPlacementsWithConfig in public Rokt.tsx
- [ ] **REN-05**: viewName parameter renamed to identifier across all APIs
- [ ] **REN-06**: purchaseFinalized parameter placementId renamed to identifier

### API Removals

- [ ] **REM-01**: setLoggingEnabled removed from all layers (TurboModule, iOS, Android, Rokt.tsx)
- [ ] **REM-02**: execute2Step/execute2StepWithConfig removed from all layers
- [ ] **REM-03**: setFulfillmentAttributes removed from all layers
- [ ] **REM-04**: setSessionId/getSessionId removed from all layers

### Event System

- [ ] **EVT-01**: iOS bridge updated to unified onEvent callback pattern (replacing individual callbacks)
- [ ] **EVT-02**: Android bridge updated to unified onEvent callback pattern
- [ ] **EVT-03**: New shoppable ads events handled (CartItemInstantPurchaseInitiated, CartItemInstantPurchase, CartItemInstantPurchaseFailure, InstantPurchaseDismissal, CartItemDevicePay)

### Shoppable Ads

- [ ] **SHP-01**: selectShoppableAds method added to TurboModule spec
- [ ] **SHP-02**: selectShoppableAds implemented in iOS bridge
- [ ] **SHP-03**: selectShoppableAds implemented in Android bridge
- [ ] **SHP-04**: selectShoppableAds exposed in public Rokt.tsx API

### Example Apps

- [ ] **APP-01**: RoktSampleApp updated for v5.0.0 API changes + shoppable ads
- [ ] **APP-02**: ExpoTestApp updated for v5.0.0 API changes + shoppable ads
- [ ] **APP-03**: Payment extension registration in native iOS AppDelegate

### Documentation

- [ ] **DOC-01**: README.md updated with v5.0.0 API surface
- [ ] **DOC-02**: MIGRATING.md created with migration guide from v4.x to v5.0.0

## v2 Requirements

(None — this covers the full v5.0.0 migration)

## Out of Scope

| Feature                       | Reason                                      |
| ----------------------------- | ------------------------------------------- |
| Google Pay                    | Apple Pay only for this cycle               |
| Web SDK support               | Different platform                          |
| New features beyond SDK 5.0.0 | Only exposing what native SDKs already have |

## Traceability

| Requirement | Phase   | Status  |
| ----------- | ------- | ------- |
| SDK-01      | Phase 1 | Pending |
| SDK-02      | Phase 1 | Pending |
| SDK-03      | Phase 1 | Pending |
| SDK-04      | Phase 1 | Pending |
| REN-01      | Phase 1 | Pending |
| REN-02      | Phase 1 | Pending |
| REN-03      | Phase 1 | Pending |
| REN-04      | Phase 1 | Pending |
| REN-05      | Phase 1 | Pending |
| REN-06      | Phase 1 | Pending |
| REM-01      | Phase 1 | Pending |
| REM-02      | Phase 1 | Pending |
| REM-03      | Phase 1 | Pending |
| REM-04      | Phase 1 | Pending |
| EVT-01      | Phase 1 | Pending |
| EVT-02      | Phase 1 | Pending |
| EVT-03      | Phase 1 | Pending |
| SHP-01      | Phase 1 | Pending |
| SHP-02      | Phase 1 | Pending |
| SHP-03      | Phase 1 | Pending |
| SHP-04      | Phase 1 | Pending |
| APP-01      | Phase 2 | Pending |
| APP-02      | Phase 2 | Pending |
| APP-03      | Phase 2 | Pending |
| DOC-01      | Phase 3 | Pending |
| DOC-02      | Phase 3 | Pending |

**Coverage:**

- v1 requirements: 26 total
- Mapped to phases: 26
- Unmapped: 0 ✓

---

_Requirements defined: 2026-04-14_
_Last updated: 2026-04-14 after scope expansion_
