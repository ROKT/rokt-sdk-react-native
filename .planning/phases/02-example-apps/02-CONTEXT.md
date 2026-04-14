# Phase 2: Example Apps - Context

**Gathered:** 2026-04-14
**Status:** Ready for planning
**Source:** User requirements + Phase 1 implementation

<domain>
## Phase Boundary

Update both example apps (RoktSampleApp and ExpoTestApp) for the v5.0.0 API changes:

1. Replace all `execute`/`execute2Step` calls with `selectPlacements`
2. Remove usage of deprecated APIs (setLoggingEnabled, setFulfillmentAttributes, setSessionId/getSessionId)
3. Add shoppable ads demonstration flow using `selectShoppableAds`
4. Register payment extension in native iOS AppDelegate code
5. Add RoktPaymentExtension library to iOS targets
6. Update attribute names and event listeners for v5.0.0 patterns

</domain>

<decisions>
## Implementation Decisions

### RoktSampleApp Updates

- Replace `Rokt.execute(...)` with `Rokt.selectPlacements(...)` throughout App.tsx
- Replace `viewName` parameter with `identifier`
- Remove any `execute2Step`, `setLoggingEnabled`, `setFulfillmentAttributes`, `setSessionId/getSessionId` usage
- Add a "Shoppable Ads" section/button that calls `Rokt.selectShoppableAds(identifier, attributes)`
- Update event listeners to handle new shoppable ads events
- iOS AppDelegate.swift: Import RoktStripePaymentExtension, register payment extension after SDK init
- Update Podfile to include RoktPaymentExtension pod

### ExpoTestApp Updates

- Same API changes as RoktSampleApp (selectPlacements, remove deprecated, add selectShoppableAds)
- Expo config plugin may need updates for the payment extension
- iOS AppDelegate: register payment extension

### Teammate's Branch Reference

- The `feat/remove-deprecated-functions` branch likely has updated sample app code
- Check `RoktSampleApp/App.tsx` and `ExpoTestApp/App.tsx` on that branch for baseline
- The teammate's branch has `RoktSampleApp/ios/AppDelegate.swift` (new Swift AppDelegate)

### Native Payment Extension Registration

```swift
// In AppDelegate.swift (after Rokt.initialize)
import RoktStripePaymentExtension

let stripeExt = RoktStripePaymentExtension(applePayMerchantId: "merchant.com.rokt.sample")
Rokt.registerPaymentExtension(stripeExt, config: ["stripeKey": "pk_test_..."])
```

### Build Verification (MANDATORY)

Every phase MUST end with a build verification task:

1. Build Rokt.Widget package
2. Install in both apps
3. Build iOS + Android for RoktSampleApp
4. Build iOS + Android for ExpoTestApp

### Claude's Discretion

- Exact UI layout for shoppable ads demo section
- Test attribute values for shoppable ads flow
- Whether to use a real or placeholder Stripe key for sample app

</decisions>

<canonical_refs>

## Canonical References

### Current Sample Apps

- `RoktSampleApp/App.tsx` — Main sample app (currently uses old execute API)
- `RoktSampleApp/ios/RoktSampleApp/AppDelegate.swift` — iOS AppDelegate (may be .m/.h)
- `RoktSampleApp/ios/Podfile` — iOS dependencies
- `RoktSampleApp/package.json` — App dependencies
- `ExpoTestApp/App.tsx` — Expo test app
- `ExpoTestApp/package.json` — Expo dependencies

### Teammate's Branch (baseline)

- `feat/remove-deprecated-functions` branch has updated sample apps

### Phase 1 Output (SDK bridge)

- `Rokt.Widget/src/Rokt.tsx` — Public API with selectPlacements + selectShoppableAds
- `Rokt.Widget/src/NativeRoktWidget.ts` — TurboModule spec

</canonical_refs>

<deferred>
## Deferred Ideas

- Documentation updates (Phase 3)

</deferred>

---

_Phase: 02-example-apps_
_Context gathered: 2026-04-14_
