# Codebase Concerns

**Analysis Date:** 2026-04-14

## Tech Debt

**Class-based Components in Production SDK:**

- Issue: `RoktEmbeddedView` components use legacy class-based React components instead of functional components with hooks
- Files: `Rokt.Widget/src/rokt-embedded-view.ios.tsx`, `Rokt.Widget/src/rokt-embedded-view.android.tsx`
- Impact: Harder to maintain, test, and optimize. Modern React ecosystem tooling favors functional components. Increases bundle size and cognitive load for integrators using modern React patterns
- Fix approach: Migrate to functional components with hooks (`useState`, `useEffect`). This requires careful testing of native event subscriptions and lifecycle management, particularly for the `NativeEventEmitter` subscription in iOS variant

**Event Subscription Lifecycle Management:**

- Issue: iOS `RoktEmbeddedView` creates event subscription at class instantiation level (line 73-80 in rokt-embedded-view.ios.tsx), not in constructor. This subscription is created outside constructor and not tied to component lifecycle
- Files: `Rokt.Widget/src/rokt-embedded-view.ios.tsx`
- Impact: Memory leaks possible if component renders multiple times; subscription cleanup only happens in `componentWillUnmount`. Event listeners may leak if errors occur during component initialization
- Fix approach: Move subscription creation into constructor, implement error handling, add safeguards for subscription cleanup. Consider using WeakMaps or ref-based cleanup

**Inconsistent Platform Implementation:**

- Issue: iOS and Android implementations of `RoktEmbeddedView` have different event handling patterns and APIs
- Files: `Rokt.Widget/src/rokt-embedded-view.ios.tsx` (uses `NativeEventEmitter`), `Rokt.Widget/src/rokt-embedded-view.android.tsx` (uses direct event handlers from native component)
- Impact: Developers must handle platform-specific behaviors. Integration bugs may differ by platform. Testing requires dual implementation validation
- Fix approach: Create a unified event abstraction layer that normalizes event structure across platforms. Document platform differences explicitly in JSDoc

**Unsafe parseInt Usage:**

- Issue: Multiple `parseInt()` calls without radix parameter throughout embedded view components
- Files: `Rokt.Widget/src/rokt-embedded-view.ios.tsx` (lines 77, 101-110), `Rokt.Widget/src/rokt-embedded-view.android.tsx` (lines 89, 102-105)
- Impact: Edge cases with strings starting with "0" could parse as octal in older JS engines. Non-numeric values silently become `NaN`. No validation of native event data
- Fix approach: Always use `parseInt(value, 10)` with explicit radix. Add validation helper: `const safeParseInt = (val: string) => { const parsed = parseInt(val, 10); return isNaN(parsed) ? 0 : parsed; }`

## Known Bugs

**Bare `catch` Block in Android Embedded View:**

- Symptoms: Render errors in `RoktEmbeddedView` are caught but only logged to console. Silent failures with null return
- Files: `Rokt.Widget/src/rokt-embedded-view.android.tsx` (lines 111-137)
- Trigger: Any error during render of native component (missing props, event handler errors, etc.)
- Workaround: Currently returns null and logs to console. App will show blank space instead of widget. Check device logs for error details
- Impact: Hard to debug - integrators may not see errors. No error boundary integration. No way to notify user of failure

**Missing Radix in parseInt (String to Number Conversion):**

- Symptoms: Unpredictable height/margin values in widget layout
- Files: `Rokt.Widget/src/rokt-embedded-view.ios.tsx`, `Rokt.Widget/src/rokt-embedded-view.android.tsx`
- Trigger: When native layer sends height or margin values as strings (e.g., "08", "09")
- Workaround: Ensure native implementation sends numeric-only strings. Use values that don't start with "0"

## Security Considerations

**RSA Encryption Key Handling in Sample App:**

- Risk: Public encryption keys are stored as constants in sample application source code
- Files: `RoktSampleApp/utils/rokt-constants.js`
- Current mitigation: These are marked as public keys (appropriate for RSA public key crypto). Sample app documentation recommends using environment-based configuration in production
- Recommendations: Verify that production apps load these keys from secure configuration, not source code. Add documentation warning about PII encryption. Document key rotation procedures

**Unvalidated Null Values in Attributes:**

- Risk: Sample app deliberately passes null values in attributes (line 236-237 in RoktSampleApp/App.tsx) to test SDK's null-handling. In production code, developers might accidentally send sensitive data as null
- Files: `RoktSampleApp/App.tsx`
- Current mitigation: SDK documentation states invalid attributes are ignored
- Recommendations: Add explicit validation in Rokt.execute() to log warnings for unexpected value types. Document which attributes can safely be null

**Credential Handling in Encryption Methods:**

- Risk: Sample app's `encrypt()` method (lines 134-143) uses node-forge library for RSA encryption. Decryption happens on server side only (appropriate), but ensure key material isn't logged
- Files: `RoktSampleApp/App.tsx`
- Current mitigation: No logging of encrypted values in sample code
- Recommendations: Ensure production apps never log plaintext PII before encryption. Add JSDoc warnings

## Performance Bottlenecks

**Duplicate Event Handler Creation:**

- Problem: Android `RoktEmbeddedView` creates new arrow function handlers on every render (lines 87, 97 in rokt-embedded-view.android.tsx)
- Files: `Rokt.Widget/src/rokt-embedded-view.android.tsx`
- Cause: `handleHeightChanged` and `handleMarginChanged` defined as class field arrow functions without memoization
- Improvement path: Convert to class methods (not arrow functions) or use `useMemo` in functional component version. This prevents unnecessary re-renders of native component

**Repeated `JSON.parse()` in Sample App:**

- Problem: Sample app calls `JSON.parse(JSON.stringify(state))` (line 224) for every execute, creating temporary copies of entire state
- Files: `RoktSampleApp/App.tsx`
- Cause: Defensive copying approach for state mutation safety
- Improvement path: Use immutable update patterns directly; only copy attributes object if modification needed

**parseInt() Performance in High-Frequency Events:**

- Problem: Height/margin changes trigger `parseInt()` on every event (multiple times per event in some cases)
- Files: `Rokt.Widget/src/rokt-embedded-view.ios.tsx` (lines 77, 101-110 all in same event), `Rokt.Widget/src/rokt-embedded-view.android.tsx`
- Cause: Redundant parsing - iOS parses once in subscription listener and again in direct event handler
- Improvement path: Parse once, cache numeric value. Add debouncing for rapid event sequences

**Unoptimized Event Listener Registry (Android Native):**

- Problem: `eventSubscriptions` map stores all active listeners with string-based keys. No pruning strategy for abandoned listeners
- Files: `Rokt.Widget/android/src/main/java/com/rokt/reactnativesdk/RNRoktWidgetModuleImpl.kt` (lines 39, 201-204)
- Cause: `startRoktEventListener()` checks only if job is active; doesn't clean up if viewName changes or component unmounts improperly
- Improvement path: Implement listener cleanup on unmount callbacks from React. Add weak references for event subscriptions

## Fragile Areas

**Platform-Specific Event Schema Mismatch:**

- Files: `Rokt.Widget/src/rokt-embedded-view.ios.tsx`, `Rokt.Widget/src/rokt-embedded-view.android.tsx`
- Why fragile: iOS uses flat event structure (`height`, `marginTop`, etc. directly on event), Android uses nested structure (`nativeEvent` property). Type definitions don't enforce this; easy to mix up
- Safe modification: Create `EventPayload` interface that's platform-agnostic. Have OS-specific adapters convert native events to canonical form before use
- Test coverage: Both platforms must be tested for events. Missing tests on one platform will miss integration issues

**Architecture Detection and Module Resolution (Rokt.tsx):**

- Files: `Rokt.Widget/src/Rokt.tsx` (lines 11-32)
- Why fragile: New Architecture detection logic checks Fabric UIManager presence, then falls back to TurboModule presence check using truthy logic that's inverted (`turboModuleCheck = NativeModules.RNRoktWidget == null` on line 23). Hard to reason about correctness
- Safe modification: Extract architecture detection to separate function with explicit return logic. Add explicit error states. Test on both old and new architecture emulators
- Test coverage: Gaps in architecture switching tests. Crashes may only surface on devices with specific React Native versions

**Rokt Config Builder Pattern:**

- Files: `Rokt.Widget/src/Rokt.tsx` (lines 172-191)
- Why fragile: `build()` method (line 188) relies on `this` type being IRoktConfig, but TypeScript's type system doesn't enforce this at compile time. Calling `build()` without setting required fields returns incomplete config
- Safe modification: Make build() return `IRoktConfig` and validate required fields before returning. Add static factory methods for common configurations
- Test coverage: No tests validating builder output shape

## Scaling Limits

**Listener Map Growth (Android):**

- Current capacity: `MAX_LISTENERS = 5` (line 340 in RNRoktWidgetModuleImpl.kt)
- Limit: Once 5 callbacks registered, oldest callbacks are dropped via LinkedHashMap's `removeEldestEntry`. This is silent - no error or warning
- Scaling path: Implement callback pooling. Switch to WeakHashMap for automatic cleanup. Add metrics/logging for callback count. Increase limit with warning system

**Event Subscription Per ViewName:**

- Current capacity: Unlimited viewNames can have active subscriptions stored in `eventSubscriptions` map
- Limit: Memory grows unbounded if app calls execute() with many different viewNames without cleanup
- Scaling path: Implement LRU cache for viewName subscriptions. Add lifecycle hooks to clean up abandoned subscriptions. Document recommendation for view name reuse

## Dependencies at Risk

**node-forge Library (Sample App Only):**

- Risk: node-forge is a large crypto library. Sample app uses it for RSA encryption. It's not declared as a production dependency (only in RoktSampleApp)
- Impact: Bundle size concern only for sample app. If production apps copy this pattern, they'll bloat their bundles
- Migration plan: Document that production apps should use native platform crypto APIs (CommonCrypto on iOS, Android Keystore). Provide migration guide from node-forge to platform-native

**Deprecated readableMapToMapOfStrings Pattern:**

- Risk: Android bridge uses `.toHashMap()?.filter { it.value is String }` pattern which relies on unsafe type casting
- Impact: Runtime crashes if non-string values slip through the bridge. No compile-time protection
- Migration plan: Create type-safe bridge serialization helpers. Use Kotlin sealed classes for attribute types

## Test Coverage Gaps

**No Unit Tests for TypeScript SDK Code:**

- What's not tested: `Rokt.tsx` module resolution, `RoktEmbeddedView` event handling, configuration builders, architecture detection
- Files: `Rokt.Widget/src/Rokt.tsx`, `Rokt.Widget/src/rokt-embedded-view.ios.tsx`, `Rokt.Widget/src/rokt-embedded-view.android.tsx`
- Risk: Refactoring breaks invisible contracts. Architecture switching logic never validated. Builder pattern misuse not caught
- Priority: HIGH - Core SDK functionality should have >80% unit test coverage

**No Integration Tests for Platform-Specific Event Flows:**

- What's not tested: Events firing from native layer, state updates in response to events, proper cleanup on component unmount
- Files: `Rokt.Widget/src/rokt-embedded-view.*.tsx`
- Risk: Platform-specific bugs only surface in real apps. Silent failures in event handling
- Priority: HIGH - Each platform needs e2e test scenarios

**No Tests for New/Old Architecture Compatibility:**

- What's not tested: Both React Native architecture modes with actual builds. Architecture detection fallback logic
- Files: `Rokt.Widget/src/Rokt.tsx`
- Risk: Breaking changes on architecture switch. Silent failures on new architecture
- Priority: MEDIUM - CI should test on both old and new arch RN versions

**No Error Handling Tests:**

- What's not tested: Native module missing, null activity on Android, invalid event payloads, render errors
- Files: All event handling and initialization code
- Risk: Error modes unknown, debugging very hard for integrators
- Priority: MEDIUM - Error states should have clear fallback behavior

**Sample App Missing Critical Test Coverage:**

- What's not tested: Encryption flow validation, 2-step data pass validation, different attribute combinations, network failure scenarios
- Files: `RoktSampleApp/App.tsx`
- Risk: Sample code is copy-pasted by integrators. Untested patterns become production patterns
- Priority: MEDIUM - Sample should demonstrate proper error handling

---

_Concerns audit: 2026-04-14_
