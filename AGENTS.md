# rokt-sdk-react-native

## Project Overview

This repository contains the Rokt React Native SDK (`@rokt/react-native-sdk`) — a bridge library that allows React Native mobile applications to integrate with Rokt's platform for displaying overlay and embedded placements. The SDK wraps native Rokt iOS and Android SDKs, exposing them to JavaScript/TypeScript through React Native's native module system. The repo also includes a sample app (`RoktSampleApp`) and an Expo test app (`ExpoTestApp`) for development and integration testing.

Owned by the **sdk-engineering** team. On-call via OpsGenie schedule: `Mobile Integrations_schedule`. Service tier: 3.

## Architecture

The SDK uses a bridge architecture connecting TypeScript to native platform SDKs:

```text
┌─────────────────────────────────────────────────┐
│              TypeScript Layer                    │
│  Rokt.tsx → NativeRoktWidget.ts (TurboModule)   │
│  RoktEmbeddedView (platform-specific views)     │
│  index.tsx (public API exports)                  │
└────────────────┬────────────────────────────────┘
                 │ React Native Bridge
     ┌───────────┴───────────┐
     ▼                       ▼
┌──────────────┐    ┌───────────────────┐
│  iOS Bridge  │    │  Android Bridge   │
│  (Swift/ObjC)│    │  (Kotlin)         │
│  RNRoktWidget│    │  RNRoktWidgetModule│
│  RoktEvent   │    │  RoktEmbedded     │
│  Manager     │    │  ViewManager      │
└──────┬───────┘    └─────────┬─────────┘
       │                      │
       ▼                      ▼
┌──────────────┐    ┌───────────────────┐
│ Rokt-Widget  │    │ com.rokt:roktsdk  │
│ iOS Pod      │    │ (Maven Central)   │
│ ~> 4.15.0    │    │ 4.14.0            │
└──────────────┘    └───────────────────┘
```

### Key Flow

1. **Initialize**: App calls `Rokt.initialize(tagId, appVersion)` → bridge routes to native `Rokt.init()`
2. **Execute**: App calls `Rokt.execute(viewName, attributes, placeholders)` → bridge calls native SDK to fetch and display content
3. **Events**: Native SDK events flow back through `RoktEventManager` → `NativeEventEmitter` in JS
4. **New Architecture**: Supports both old and new React Native architectures (TurboModules / Fabric)

## Tech Stack

| Component            | Technology            | Version                                   |
| -------------------- | --------------------- | ----------------------------------------- |
| TypeScript SDK       | TypeScript            | ^5.0.4                                    |
| React Native         | react-native          | >= 0.55.4 (peer dep), 0.81.5 (sample app) |
| React                | react                 | 19.1.0 (sample app)                       |
| Node.js              | Node.js               | 20 (CI), >= 18 (engines)                  |
| Android native       | Kotlin                | 1.8.21                                    |
| Android SDK          | com.rokt:roktsdk      | 4.14.0                                    |
| Android min SDK      |                       | 21                                        |
| Android compile SDK  |                       | 32                                        |
| iOS native           | Swift / Objective-C++ |                                           |
| iOS SDK              | Rokt-Widget pod       | ~> 4.15.0                                 |
| iOS min platform     |                       | 10.0                                      |
| Expo plugin          | @expo/config-plugins  | >= 7.0.0 (optional peer dep)              |
| Ruby (for CocoaPods) | Ruby                  | >= 2.7.6                                  |

## Development Guide

### Prerequisites

- React Native development environment ([setup guide](https://reactnative.dev/docs/environment-setup))
- Node.js >= 18 (CI uses 20)
- Ruby >= 2.7.6
- For Android: Android Studio with SDK
- For iOS: Xcode + CocoaPods (`sudo gem install cocoapods`)

### Quick Start

```shell
# Clone and install SDK dependencies
git clone https://github.com/ROKT/rokt-sdk-react-native.git
cd rokt-sdk-react-native

# Install SDK dependencies and build
cd Rokt.Widget
npm ci
npm run build
npm run build:plugin

# Build the package tarball
npm pack

# Set up sample app
cd ../RoktSampleApp
npm install

# Run sample app
npx react-native run-android   # Android
npx react-native run-ios       # iOS
```

### Common Tasks

**Expo Test App:**

```shell
cd ExpoTestApp
npm install
npx expo prebuild --clean
npx expo run:ios     # or npx expo run:android
```

## Build, Test & Lint Commands

### Rokt.Widget (SDK)

| Command                | Description                    |
| ---------------------- | ------------------------------ |
| `npm ci`               | Install dependencies (CI-safe) |
| `npm run lint`         | Run ESLint                     |
| `npm run build`        | Build TypeScript → `dist/`     |
| `npm run build:plugin` | Build Expo config plugin       |
| `npm run clean:plugin` | Clean Expo plugin build        |
| `npm pack`             | Create publishable tarball     |

### RoktSampleApp

| Command           | Description                                 |
| ----------------- | ------------------------------------------- |
| `npm run android` | Run on Android (`react-native run-android`) |
| `npm run ios`     | Run on iOS (`react-native run-ios`)         |
| `npm run start`   | Start Metro bundler                         |
| `npm run lint`    | Run ESLint                                  |
| `npm run test`    | Run Jest tests                              |

### ExpoTestApp

| Command            | Description                              |
| ------------------ | ---------------------------------------- |
| `npm run start`    | Start Expo dev client                    |
| `npm run android`  | Run on Android (`expo run:android`)      |
| `npm run ios`      | Run on iOS (`expo run:ios`)              |
| `npm run prebuild` | Clean prebuild (`expo prebuild --clean`) |

### Trunk (Code Quality)

```shell
trunk fmt <files>     # Auto-format
trunk check <files>   # Lint check
```

Enabled linters: swiftlint, ktlint, markdownlint, prettier, eslint, shellcheck, shfmt, yamllint, osv-scanner, trufflehog, checkov, dotenv-linter, buildifier, oxipng.

## CI/CD Pipeline

CI/CD runs on **GitHub Actions**. Four workflows:

### `pull_request.yml` — PR Validation

1. **Trunk Check** — Runs trunk linting on PR diff
2. **Build Package** — `npm ci` → lint → build TypeScript → build plugin → `npm pack` (Ubuntu, Node 20)
3. **Build & Test iOS** — Builds RoktSampleApp for iOS Simulator, runs xcodebuild tests (macOS)
4. **Build & Test Android** — Bundles JS, builds APK via Gradle `assembleDebug` (Ubuntu)
5. **Notify GChat** — Sends notification for non-draft PRs

### `release-from-main.yml` — Release (triggered on `VERSION` file change to `main`)

1. Build Package → Build & Test iOS → Build & Test Android
2. Read version from `VERSION` file
3. Publish tarball to **npm** (`@rokt/react-native-sdk`) with OIDC trusted publishing
4. Extract release notes from `CHANGELOG.md`
5. Create GitHub Release with tag and tarball

### `draft-release-publish.yml` — Create Draft Release (manual trigger)

- Bumps version (major/minor/patch) in `VERSION`, `package.json`, sample app versions
- Updates `CHANGELOG.md`
- Creates a PR to `main` on branch `release/<version>`

### `trunk-upgrade.yml` — Trunk Tool Upgrades (monthly cron + manual)

- Runs `trunk upgrade` via shared workflow

## Project Structure

```text
rokt-sdk-react-native/
├── Rokt.Widget/                 # The published SDK package (@rokt/react-native-sdk)
│   ├── src/                     # TypeScript source
│   │   ├── index.tsx            # Public API exports
│   │   ├── Rokt.tsx             # Main Rokt class (initialize, execute, etc.)
│   │   ├── NativeRoktWidget.ts  # TurboModule spec (New Architecture)
│   │   ├── rokt-embedded-view.*.tsx  # Platform-specific embedded view components
│   │   └── RoktNativeWidgetNativeComponent.ts  # Fabric component
│   ├── android/                 # Android native bridge (Kotlin)
│   │   ├── build.gradle         # Android build config
│   │   └── src/
│   │       ├── main/java/com/rokt/reactnativesdk/  # Shared implementation
│   │       ├── newarch/         # New Architecture bridge module
│   │       └── oldarch/         # Old Architecture bridge module
│   ├── ios/                     # iOS native bridge (Swift/ObjC/ObjC++)
│   ├── plugin/                  # Expo config plugin source
│   ├── rokt-react-native-sdk.podspec  # CocoaPods spec
│   ├── package.json             # NPM package definition
│   └── tsconfig.json            # TypeScript config
├── RoktSampleApp/               # Bare React Native sample app
│   ├── App.tsx                  # Demo UI with init/execute flows
│   ├── android/                 # Android native project
│   ├── ios/                     # iOS native project
│   └── utils/                   # Constants and helpers
├── ExpoTestApp/                 # Expo managed workflow test app
├── .github/
│   ├── workflows/               # CI/CD workflows (4 total)
│   └── actions/                 # Composite actions (build-package, build-ios, build-android, etc.)
├── .cortex/catalog/             # Service catalog metadata
├── .trunk/                      # Trunk code quality config
├── VERSION                      # Current version (4.12.0)
└── CHANGELOG.md                 # Keep a Changelog format
```

## Observability

- **Datadog Dashboard**: [Mobile SDK Detailed Error View](https://rokt.datadoghq.com/dashboard/nsi-c8c-gtd)
- **Cortex Tag**: `react-native-sdk`

## Team Ownership

- **CODEOWNERS**: `@ROKT/sdk-engineering` (all files)
- **Cortex Owner**: `sdk-engineering` group
- **On-call**: OpsGenie schedule `Mobile Integrations_schedule`

## Maintaining This Document

When making changes to this repository that affect the information documented here
(build commands, dependencies, architecture, deployment configuration, etc.),
please update this document to keep it accurate. This file is the primary reference
for AI coding assistants working in this codebase.
