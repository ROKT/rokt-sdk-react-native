# Technology Stack

**Analysis Date:** 2026-04-14

## Languages

**Primary:**

- TypeScript 5.0.4 - SDK implementation and type definitions
- Swift / Objective-C - iOS native bridge implementation (`Rokt.Widget/ios/`)
- Kotlin 1.8.21 / Java - Android native bridge implementation (`Rokt.Widget/android/src/`)
- JavaScript/JSX - React Native components and sample applications

**Secondary:**

- Bash/Shell - Build scripts and CI/CD workflows
- Ruby - CocoaPods dependency management (iOS)
- Gradle / Kotlin - Android build system

## Runtime

**Environment:**

- React Native 0.55.4+ (peer dependency, tested with 0.81.5)
- Node.js 18+ (for development)
- iOS 10.0+ (minimum platform requirement per podspec)
- Android API 21+ (minSdkVersion)

**Package Manager:**

- npm (primary) - `package-lock.json` present
- CocoaPods - iOS dependency management
- Gradle - Android dependency management

## Frameworks

**Core:**

- React Native 0.81.5 (tested version, supports >=0.55.4)
- Expo 54.0.25 (for ExpoTestApp, optional for managed workflow)
- React 19.1.0

**Testing:**

- Jest 29.6.3 - Unit test framework (RoktSampleApp)
- React Test Renderer 19.1.0 - Component testing

**Build/Dev:**

- TypeScript 5.0.4 - Transpilation and type checking
- ESLint 8.41.0 with @typescript-eslint/eslint-plugin 5.59.7 - Code linting
- Babel 7.25.2+ - JavaScript transpilation
- Metro Bundler - React Native module bundler (via @react-native/metro-config)
- expo-module-scripts 2.0.0 - Expo plugin build tools

## Key Dependencies

**Critical:**

- @expo/config-plugins 7.2.5 (optional peer, for Expo config plugin support)
- Rokt native SDKs (managed via native package managers):
  - iOS: Rokt-Widget CocoaPod >=4.15, <5 (rokt-react-native-sdk.podspec)
  - Android: com.rokt:roktsdk:4.14.1 (Rokt.Widget/android/build.gradle)

**Infrastructure:**

- react-native (>=0.55.4) - Core framework dependency
- @types/react-native 0.68.0 - Type definitions
- @types/react 19.0.0 - React type definitions
- @types/jest 27.5.1 - Jest type definitions

**Sample App Specific:**

- @react-native-community/checkbox 0.5.12 - Checkbox UI component
- crypto-js 4.0.0 - Cryptographic utilities
- node-forge 1.3.1 - TLS and cryptography
- react-native-toast-message 2.1.5 - Toast notifications
- @react-native/babel-preset 0.81.5 - Babel preset for React Native
- @react-native/eslint-config 0.81.5 - ESLint configuration

## Configuration

**Environment:**

- Build-time: Uses package.json version field (4.12.2) and VERSION file
- Development: TSConfig targets ES6, uses Node module resolution
- Platform detection: Uses UIManager.hasViewManagerConfig and Fabric renderer detection to switch between old and new React Native architectures

**Build:**

- TypeScript compilation: `Rokt.Widget/tsconfig.json` - strict mode enabled
- NPM scripts: `build` (tsc), `lint` (eslint), `test` (jest for sample app)
- Platform-specific builds:
  - iOS: Uses Xcode project in `Rokt.Widget/ios/RNRoktWidget.xcodeproj`
  - Android: Gradle-based, configures old and new architecture variants via build.gradle

**Native Codegen:**

- React Native Codegen enabled in `Rokt.Widget/package.json` codegenConfig
- Spec: RNRoktWidgetSpec type "all"
- iOS component: RoktNativeWidgetComponentView
- Android package: com.rokt.reactnativesdk

## Platform Requirements

**Development:**

- Ruby 2.7.6+ (for CocoaPods)
- Xcode (iOS development)
- Android Studio (Android development)
- CocoaPods (iOS: `sudo gem install cocoapods`)
- macOS-specific workaround for M1/M2: Use x86_64 architecture for pod install

**Production:**

- Deployment: Published to NPM as @rokt/react-native-sdk
- Distribution: Automated GitHub Actions workflows (release-from-main.yml)
- Trusted publishing: Uses npm OIDC for npmjs.org registry
- Platforms supported: iOS, Android, Expo (bare and managed workflows via expo-dev-client)

---

_Stack analysis: 2026-04-14_
