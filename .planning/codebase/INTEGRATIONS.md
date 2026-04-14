# External Integrations

**Analysis Date:** 2026-04-14

## APIs & External Services

**Rokt Backend Services:**

- Rokt Experience API - Primary integration for fetching and displaying content placements
  - SDK Access: Via native Rokt Widget SDKs (iOS and Android)
  - Tag ID: ROKT_TAG_ID passed to `Rokt.initialize(roktTagId, appVersion)` in `Rokt.Widget/src/Rokt.tsx`
  - Implementation: Bridge translates React Native calls to native SDK methods
  - Environment switching: `setEnvironmentToStage()` and `setEnvironmentToProd()` methods available

**Content Rendering:**

- Rokt provides content templates for two placement types:
  - Overlay placements (full-screen modal experiences)
  - Embedded placements (integrated into app layouts via `RoktEmbeddedView` component)

## Data Storage

**Databases:**

- None - SDK is client-side only, no local database dependency
- State management: Handled by native SDKs (iOS Rokt-Widget, Android roktsdk)

**File Storage:**

- Local filesystem only (via native platform APIs)
- No cloud storage integration

**Caching:**

- SDK provides cache configuration: `CacheConfig` class in `Rokt.Widget/src/Rokt.tsx`
  - `cacheDurationInSeconds` - Duration to cache experiences (default 90 minutes)
  - `cacheAttributes` - Optional attributes to use as cache key (if null, all attributes used)
- Usage: Pass via `RoktConfigBuilder` when calling `execute()` or `execute2Step()`

## Authentication & Identity

**Auth Provider:**

- Custom / Client-provided
- Implementation: SDK accepts user attributes directly
  - Email, firstname, lastname, mobile, postcode, country passed as dictionary to `execute()` method
  - No built-in auth mechanism; consumer app responsible for authentication
  - Session ID support: `setSessionId()` and `getSessionId()` for cross-integration consistency

## Monitoring & Observability

**Error Tracking:**

- None detected
- Logging: `setLoggingEnabled(boolean)` method in `Rokt.Widget/src/Rokt.tsx` for SDK-level debug logging

**Logs:**

- SDK exposes debug logging via native implementations
- Consumer app responsible for application-level logging
- No structured logging framework integrated

## CI/CD & Deployment

**Hosting:**

- npm Registry (npmjs.org) - Published as @rokt/react-native-sdk
- GitHub repository - https://github.com/ROKT/rokt-sdk-react-native

**CI Pipeline:**

- GitHub Actions (`.github/workflows/`)
  - `release-from-main.yml` - Automated release workflow triggered on VERSION file changes
  - `pull_request.yml` - PR validation workflow
  - `draft-release-publish.yml` - Draft release creation
  - `trunk-upgrade.yml` - Trunk dependency upgrades
  - `zizmor.yml` - Security scanning (zizmor)

**Release Process:**

- Trigger: Update VERSION file and push to main branch
- Build: Package SDK, build iOS and Android test apps in parallel
- Test: Run iOS and Android builds as part of release validation
- Publish: npm publish via OIDC trusted publishing (no manual npm token needed)
- GitHub Release: Auto-generated from CHANGELOG.md entries

## Environment Configuration

**Required env vars:**

- ROKT_TAG_ID - Partner-specific tag for Rokt backend (string, passed to initialize())
- App version - String passed to initialize() to track which app version made requests

**Secrets location:**

- None committed to repository
- ROKT_TAG_ID handled by consumer app (not SDK responsibility)
- npm OIDC trusted publishing - No stored npm tokens needed

## Webhooks & Callbacks

**Incoming:**

- None - SDK is pull-only from consumer app perspective

**Outgoing:**

- Callback function: `onLoad` callback passed to `execute()` and `execute2Step()` methods
  - Fired when Rokt content loads successfully
  - Signature: `() => void` in `Rokt.Widget/src/Rokt.tsx:59`

**Event Callbacks (Native Bridge):**

- iOS: RoktEventManager (`Rokt.Widget/ios/RoktEventManager.m`) handles native->JS events
- Android: RoktEmbeddedViewManager manages event callbacks from native layer
- Purchase events: `purchaseFinalized(placementId, catalogItemId, success)` for commerce tracking

## Native SDK Dependencies

**iOS:**

- Rokt-Widget CocoaPod >=4.15, <5 (primary)
  - Source: CocoaPods repository (rokt-react-native-sdk.podspec)
  - SPM bridge: Also registers via Swift Package Manager for RN 0.75+ (spm_dependency in podspec)
  - SPM URL: https://github.com/ROKT/rokt-sdk-ios.git

**Android:**

- com.rokt:roktsdk:4.14.1
  - Source: Maven Central Repository (Rokt.Widget/android/build.gradle)
  - Autolinking: Resolved automatically via React Native autolinking

## Fulfillment & Commerce Integration

**Fulfillment Attributes:**

- Method: `setFulfillmentAttributes(attributes)` in `Rokt.Widget/src/Rokt.tsx`
- Purpose: Set user fulfillment data after purchase or user action

**Purchase Tracking:**

- Method: `purchaseFinalized(placementId, catalogItemId, success)` in `Rokt.Widget/src/Rokt.tsx`
- Purpose: Notify Rokt of purchase completion for analytics and attribution

---

_Integration audit: 2026-04-14_
