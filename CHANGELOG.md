<!-- markdownlint-disable MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [5.2.0] - 2026-10-26

### Added

- Support named embedded placements and reliable native events ([#308](https://github.com/ROKT/rokt-sdk-react-native/pull/308))
- Add CNAME and built-in PayPal redirect callback APIs ([#303](https://github.com/ROKT/rokt-sdk-react-native/pull/303))

### Fixed

- Ignore wrongly typed config values and reset recycled embedded views ([#318](https://github.com/ROKT/rokt-sdk-react-native/pull/318))
- Keep embedded Rokt view at SDK-reported height on New Architecture ([#307](https://github.com/ROKT/rokt-sdk-react-native/pull/307))
- Render iOS embedded layouts in bridgeless apps ([#296](https://github.com/ROKT/rokt-sdk-react-native/pull/296))
- Skip explicit Kotlin plugin when AGP registers the kotlin extension ([#301](https://github.com/ROKT/rokt-sdk-react-native/pull/301))

### Changed

- Harden releases from maintenance branches ([#323](https://github.com/ROKT/rokt-sdk-react-native/pull/323))
- Bump actions/download-artifact from 4.3.0 to 8.0.2 ([#322](https://github.com/ROKT/rokt-sdk-react-native/pull/322))
- Bump actions/create-github-app-token from 3.2.0 to 3.3.0 in the github-actions-patch-minor group ([#321](https://github.com/ROKT/rokt-sdk-react-native/pull/321))
- Bump the gradle-patch-minor group in /Rokt.Widget/android with 2 updates ([#320](https://github.com/ROKT/rokt-sdk-react-native/pull/320))
- Bump com.rokt:roktsdk from 6.1.4 to 6.2.1 in /Rokt.Widget/android in the gradle-patch-minor group ([#314](https://github.com/ROKT/rokt-sdk-react-native/pull/314))
- Publish only the verified release tarball and split the GitHub release job ([#317](https://github.com/ROKT/rokt-sdk-react-native/pull/317))
- Bump the github-actions-patch-minor group with 2 updates ([#315](https://github.com/ROKT/rokt-sdk-react-native/pull/315))
- Upgrade trunk ([#310](https://github.com/ROKT/rokt-sdk-react-native/pull/310))
- Bump com.rokt:roktsdk from 6.1.3 to 6.1.4 in /Rokt.Widget/android in the gradle-patch-minor group ([#309](https://github.com/ROKT/rokt-sdk-react-native/pull/309))
- Read release version and notes from step env in publish workflow ([#312](https://github.com/ROKT/rokt-sdk-react-native/pull/312))
- Scope release publish permissions to the release job ([#313](https://github.com/ROKT/rokt-sdk-react-native/pull/313))
- Add agent instructions with public repository confidentiality rules ([#311](https://github.com/ROKT/rokt-sdk-react-native/pull/311))
- Bump com.rokt:roktsdk from 6.1.1 to 6.1.3 in /Rokt.Widget/android in the gradle-patch-minor group ([#306](https://github.com/ROKT/rokt-sdk-react-native/pull/306))
- Inherit org default PR template ([#305](https://github.com/ROKT/rokt-sdk-react-native/pull/305))
- Add a path-aware React Native PR gate ([#299](https://github.com/ROKT/rokt-sdk-react-native/pull/299))
- Bump com.rokt:roktsdk from 6.0.2 to 6.1.1 in /Rokt.Widget/android ([#302](https://github.com/ROKT/rokt-sdk-react-native/pull/302))
- Bump trunk-io/trunk-action from 1.3.1 to 2.0.0 ([#298](https://github.com/ROKT/rokt-sdk-react-native/pull/298))
- Upgrade trunk ([#300](https://github.com/ROKT/rokt-sdk-react-native/pull/300))
- Fix misleading Rokt SDK README integration guides ([#295](https://github.com/ROKT/rokt-sdk-react-native/pull/295))
- Bump com.rokt:roktsdk from 6.0.1 to 6.0.2 in /Rokt.Widget/android ([#294](https://github.com/ROKT/rokt-sdk-react-native/pull/294))
- Upgrade trunk ([#293](https://github.com/ROKT/rokt-sdk-react-native/pull/293))

## [5.1.2] - 2026-07-29

### Fixed

- Configure embedded views on New Architecture ([#291](https://github.com/ROKT/rokt-sdk-react-native/pull/291))
- Embedded view collapsing to zero height in a column container ([#290](https://github.com/ROKT/rokt-sdk-react-native/pull/290))

### Changed

- Upgrade trunk ([#282](https://github.com/ROKT/rokt-sdk-react-native/pull/282))
- Bump actions/setup-node from 6.4.0 to 7.0.0 ([#283](https://github.com/ROKT/rokt-sdk-react-native/pull/283))
- Bump actions/checkout from 6.0.3 to 7.0.1 ([#284](https://github.com/ROKT/rokt-sdk-react-native/pull/284))

## [5.1.1] - 2026-07-23

### Added

- Update to Latest Rokt SDKs ([#286](https://github.com/ROKT/rokt-sdk-react-native/pull/286))
- Updated Rokt native iOS SDK to 5.3.0.
- Updated Rokt native Android SDK to 6.0.1.

### Changed

- Fix publishing npm requirements ([#288](https://github.com/ROKT/rokt-sdk-react-native/pull/288))

## [5.1.0] - 2026-07-22

### Added

- Update to Latest Rokt SDKs ([#286](https://github.com/ROKT/rokt-sdk-react-native/pull/286))

## [5.0.2] - 2026-06-22

### Changed

- Bump native Android SDK to 5.1.1 ([#278](https://github.com/ROKT/rokt-sdk-react-native/pull/278))
- Support maintenance-branch releases without clobbering latest ([#277](https://github.com/ROKT/rokt-sdk-react-native/pull/277))
- Align release automation naming ([#274](https://github.com/ROKT/rokt-sdk-react-native/pull/274))

## [5.0.1] - 2026-06-05

### Fixed

- fix(android): render embedded placements on New Architecture via EventDispatcher

## [5.0.0] - 2026-04-16

### Changed

- **BREAKING**: Renamed `execute()` to `selectPlacements()` with `identifier` parameter replacing `viewName`.
- **BREAKING**: Removed `execute2Step()`, `setLoggingEnabled()`, and `setFulfillmentAttributes()`.
- **BREAKING**: Unified callback architecture into a single `RoktEvents` event stream via `NativeEventEmitter`.
- Updated native SDK dependencies to iOS SDK 5.0 and Android SDK 5.0.

### Added

- Shoppable Ads support.
- New `RoktConfig` parameter for `selectPlacements()`.

For a full migration guide, see [MIGRATING.md](./MIGRATING.md#migrating-from-v4x-to-v500).

## [4.12.2] - 2026-03-05

### Updated

- Updated Cocoapods dependency to loosely version the Rokt Widget from version 4.15.0 to less than 5.0.0

## [4.12.1] - 2026-03-03

### Changed

- Updated Rokt Android SDK to `4.14.0`.
- SPM fallback option iOS native

## [4.12.0] - 2026-02-04

### Added

- Added support for getting and setting session ID. If you use multiple integrations, such as webview and native within your app you can now set session ID so it is maintained across integration types.

## [4.11.4] - 2025-12-15

### Changed

- iOS embedded view resolving in old and new architectures

### Fixed

- Fix Android build error with ReactNative SDK version 0.81.5

## [4.11.3] - 2025-12-10

### Changed

- Updated Rokt native iOS SDK to [4.14.5](https://github.com/ROKT/rokt-sdk-ios/blob/main/CHANGELOG.md#4145---2025-12-10).
- Reverted iOS view hierarchy changes
- Simplified Expo config plugin - autolinking now handles all native setup automatically
- Updated Rokt native Android SDK version to `4.12.1`

## [4.11.2] - 2025-11-20

### Changes

- Updated Rokt native iOS SDK to [4.14.4](https://github.com/ROKT/rokt-sdk-ios/blob/main/CHANGELOG.md#4144---2025-11-20).

## [4.11.1] - 2025-11-14

### Changes

- Updated Rokt native iOS SDK version to `4.14.3`.

### Fixed

- iOS view hierarchy corruption in New Architecture

## [4.11.0] - 2025-09-03

### Changes

- Updated Rokt native SDK versions. Android `4.11.0`, iOS `4.14.0`

## [4.10.2] - 2025-07-29

### Fixed

- iOS native component binding and architecture detection

## [4.10.1] - 2025-07-13

### Fixed

- Fix npm publish issue

## [4.10.0] - 2025-07-04

### Added

- New Architecture support
- Real time events
- Support new response action type `ExternalPaymentTrigger`
- Sessions are now retained between app restarts

[unreleased]: https://github.com/ROKT/rokt-sdk-react-native/compare/5.2.0...HEAD
[5.2.0]: https://github.com/ROKT/rokt-sdk-react-native/compare/5.1.2...5.2.0
[5.1.2]: https://github.com/ROKT/rokt-sdk-react-native/compare/5.1.1...5.1.2
[5.1.1]: https://github.com/ROKT/rokt-sdk-react-native/compare/5.0.2...5.1.1
[5.1.0]: https://github.com/ROKT/rokt-sdk-react-native/compare/5.0.2...5.1.0
[5.0.2]: https://github.com/ROKT/rokt-sdk-react-native/compare/5.0.1...5.0.2
[5.0.1]: https://github.com/ROKT/rokt-sdk-react-native/compare/5.0.0...5.0.1
[5.0.0]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.12.2...5.0.0
[4.12.2]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.12.1...4.12.2
[4.12.1]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.12.0...4.12.1
[4.12.0]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.11.4...4.12.0
[4.11.4]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.11.3...4.11.4
[4.11.3]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.11.2...4.11.3
[4.11.2]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.11.1...4.11.2
[4.11.1]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.11.0...4.11.1
[4.11.0]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.10.2...4.11.0
[4.10.2]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.10.1...4.10.2
[4.10.1]: https://github.com/ROKT/rokt-sdk-react-native/compare/4.10.0...4.10.1
[4.10.0]: https://github.com/ROKT/rokt-sdk-react-native/compare/600533ed8b451817a169d1bebb916b3dc1aab8ee...4.10.0
