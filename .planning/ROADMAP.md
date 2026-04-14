# Roadmap: Rokt RN SDK v5.0.0 Migration & Shoppable Ads

**Created:** 2026-04-14
**Milestone:** v5.0.0 — SDK Migration & Shoppable Ads
**Phases:** 3
**Requirements:** 26

## Phase Overview

| #   | Phase               | Goal                                                                                                      | Requirements                                               | Success Criteria |
| --- | ------------------- | --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- | ---------------- |
| 1   | SDK Bridge & Events | Update both SDKs to 5.0.0, rename APIs, remove deprecated methods, update event system, add shoppable ads | SDK-01..04, REN-01..06, REM-01..04, EVT-01..03, SHP-01..04 | 6                |
| 2   | Example Apps        | Update sample apps for v5.0.0 API + shoppable ads demo                                                    | APP-01..03                                                 | 3                |
| 3   | Documentation       | Update README and create migration guide                                                                  | DOC-01..02                                                 | 2                |

---

## Phase 1: SDK Bridge & Events

**Goal:** Update iOS SDK to 5.0.0 and Android SDK to 5.0.0. Rename execute->selectPlacements, remove deprecated APIs, update to unified onEvent callback pattern, and add selectShoppableAds. Leverage teammate's `feat/remove-deprecated-functions` branch.

**Requirements:** SDK-01, SDK-02, SDK-03, SDK-04, REN-01, REN-02, REN-03, REN-04, REN-05, REN-06, REM-01, REM-02, REM-03, REM-04, EVT-01, EVT-02, EVT-03, SHP-01, SHP-02, SHP-03, SHP-04

**Plans:** 3 plans

Plans:

- [ ] 01-01-PLAN.md — Apply teammate baseline + clean TypeScript and Android layers
- [ ] 01-02-PLAN.md — Apply teammate baseline + clean iOS bridge and event manager
- [ ] 01-03-PLAN.md — Android event additions, barrel exports, cross-platform verification

**Success Criteria:**

1. iOS podspec has Rokt-Widget >= 5.0.0, Android build.gradle has roktsdk 5.0.0
2. selectPlacements/selectPlacementsWithConfig work on both platforms (execute removed)
3. setLoggingEnabled, execute2Step, setFulfillmentAttributes, setSessionId/getSessionId all removed
4. selectShoppableAds callable from RN JS on both platforms
5. Unified onEvent callback pattern used for all placement/shoppable ads events
6. Both old and new RN architecture paths compile

**Depends on:** None

---

## Phase 2: Example Apps

**Goal:** Update RoktSampleApp and ExpoTestApp for v5.0.0 API changes and add shoppable ads demonstration with native payment extension registration.

**Requirements:** APP-01, APP-02, APP-03

**Success Criteria:**

1. RoktSampleApp uses selectPlacements (not execute) and demonstrates shoppable ads
2. ExpoTestApp uses selectPlacements and demonstrates shoppable ads
3. registerPaymentExtension called in iOS AppDelegate native code

**Depends on:** Phase 1

---

## Phase 3: Documentation

**Goal:** Update README.md with v5.0.0 API surface and create MIGRATING.md guide.

**Requirements:** DOC-01, DOC-02

**Success Criteria:**

1. README.md reflects all v5.0.0 API changes (selectPlacements, selectShoppableAds, removed methods)
2. MIGRATING.md covers all breaking changes with before/after code examples

**Depends on:** Phase 1

---

_Roadmap created: 2026-04-14_
_Last updated: 2026-04-14 after phase 1 planning_
