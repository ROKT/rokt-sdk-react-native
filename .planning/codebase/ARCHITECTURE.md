# Architecture

**Analysis Date:** 2026-04-14

## Pattern Overview

**Overall:** Bridge-based layered architecture with platform-specific native implementations.

**Key Characteristics:**

- **JavaScript-to-Native Bridge**: React Native bridge pattern connecting TypeScript/JavaScript layer to native Kotlin (Android) and Objective-C/Swift (iOS) implementations
- **Platform Abstraction**: Platform-specific variants (`.ios.tsx`, `.android.tsx`) that export a unified interface
- **TurboModule Architecture**: Supports both React Native Old Architecture (ViewManagers/Bridges) and New Architecture (TurboModules/Fabric)
- **Event-Driven Communication**: Native-to-JS communication via NativeEventEmitter for asynchronous events and callbacks
- **Configuration Builder Pattern**: Fluent builder for Rokt configuration options

## Layers

**Presentation Layer (JavaScript/TypeScript):**

- Purpose: Public API and React component interface for application developers
- Location: `src/`
- Contains: TypeScript interfaces, React components, configuration builders
- Depends on: NativeModules, react-native
- Used by: React Native applications integrating the SDK

**Bridge Layer (Native Module Interface):**

- Purpose: Define contract between JavaScript and native implementations; handle module registration
- Location: `src/NativeRoktWidget.ts` (TurboModule spec) and native code (`ios/`, `android/`)
- Contains: TurboModule Spec definition, native module implementations
- Depends on: React Native core, native Rokt SDK
- Used by: Presentation layer and platform-specific implementations

**Platform-Specific Implementation Layer (iOS):**

- Purpose: Bridge JavaScript calls to iOS-native Rokt Widget SDK
- Location: `ios/RNRoktWidget.h`, `ios/RNRoktWidget.mm`, `ios/RoktEventManager.m`
- Contains: Objective-C/C++ bridge modules, event manager
- Depends on: React Native framework (RCTBridgeModule/NativeRoktWidgetSpec), Rokt-Widget CocoaPods framework
- Used by: React Native runtime when running on iOS

**Platform-Specific Implementation Layer (Android):**

- Purpose: Bridge JavaScript calls to Android-native Rokt Widget SDK
- Location: `android/src/main/java/com/rokt/reactnativesdk/` and architecture variants
- Contains: Kotlin modules (RNRoktWidgetModuleImpl), view managers, package definitions
- Depends on: React Native framework (ReactContextBaseJavaModule), Rokt SDK from Maven Central, Android framework
- Used by: React Native runtime when running on Android

**Component Layer (Embedded View):**

- Purpose: Provide React component wrapper for embedded Rokt widget placements
- Location: `src/rokt-embedded-view.ts`, `src/rokt-embedded-view.ios.tsx`, `src/rokt-embedded-view.android.tsx`
- Contains: RoktEmbeddedView class component with platform-specific event handling
- Depends on: RoktNativeWidgetNativeComponent, React Native event system
- Used by: Application developers for rendering embedded widget placements

## Data Flow

**Initialization Flow:**

1. Application calls `Rokt.initialize(roktTagId, appVersion)` from JavaScript
2. Rokt.tsx routes call to TurboModule (RNRoktWidget)
3. Android: RNRoktWidgetModuleImpl.initialize() → calls native Rokt.init()
4. iOS: RNRoktWidget.mm → calls native Rokt initialization
5. Native layer initializes Rokt SDK with provided credentials

**Execution Flow (Placement):**

1. Application calls `Rokt.execute(viewName, attributes, placeholders, config?)`
2. JavaScript layer passes through to native TurboModule
3. Native module invokes Rokt SDK execute() with parameters
4. Rokt SDK communicates with backend to fetch content
5. Native layer renders content in the specified view/placeholder
6. Native layer emits RoktEvents via NativeEventEmitter for: PlacementReady, FirstPositiveEngagement, etc.
7. JavaScript listens to RoktEvents and updates component state

**Embedded View Flow:**

1. Application renders `<RoktEmbeddedView placeholderName="placeholder1" />`
2. Component mounts RoktNativeWidgetNativeComponent with placeholderName prop
3. Native widget manager receives placeholder and registers in Rokt SDK
4. User interacts with widget → native layer sends height/margin changed events
5. RoktEmbeddedView updates internal state and re-renders with new dimensions
6. Event emitter delivers RoktEvents from native layer to JavaScript listeners

**State Management:**

- **JS State**: Component local state in RoktEmbeddedView (height, margins, placeholderName)
- **Native State**: Rokt SDK maintains internal state for executions, placements, events in native layer
- **Event Flow**: Unidirectional from native → JS via NativeEventEmitter and TurboModule callbacks
- **Configuration**: Builder pattern allows immutable configuration construction in JS before passing to native

## Key Abstractions

**Rokt (Abstract Class):**

- Purpose: Main SDK API - static methods for initialization, execution, and configuration
- Examples: `src/Rokt.tsx`
- Pattern: Static facade over native module with optional configuration support
- Key Methods:
  - `initialize(roktTagId, appVersion, fontFilesMap?)`: SDK initialization
  - `execute(viewName, attributes, placeholders, roktConfig?)`: Load and render placement
  - `execute2Step(viewName, attributes, placeholders, roktConfig?)`: Two-step execution for fulfillment
  - `setFulfillmentAttributes(attributes)`: Update attributes for fulfillment flow
  - `purchaseFinalized(placementId, catalogItemId, success)`: Signal purchase completion

**RoktEmbeddedView (React Component):**

- Purpose: Wrapper component for rendering embedded widget placements
- Examples: `src/rokt-embedded-view.ios.tsx`, `src/rokt-embedded-view.android.tsx`
- Pattern: Class component with internal state management for layout dimensions
- Responsibilities:
  - Mount native widget via RoktNativeWidgetNativeComponent
  - Listen to native height/margin changed events
  - Update state to trigger re-render with correct dimensions
  - Handle cleanup on unmount

**IRoktConfig / RoktConfigBuilder:**

- Purpose: Immutable configuration for Rokt executions
- Examples: `src/Rokt.tsx` (lines 147-191)
- Pattern: Builder pattern with fluent interface
- Properties:
  - `colorMode`: "light" | "dark" | "system" - UI appearance preference
  - `cacheConfig`: Cache duration and attributes for content caching

**CacheConfig:**

- Purpose: Control caching behavior for placements
- Examples: `src/Rokt.tsx` (lines 155-164)
- Properties:
  - `cacheDurationInSeconds`: Duration to cache content
  - `cacheAttributes`: Optional attributes to use as cache key

**NativeRoktWidget (TurboModule Spec):**

- Purpose: Define native module interface for both architectures
- Examples: `src/NativeRoktWidget.ts`
- Pattern: TurboModule interface with methods for initialization, execution, configuration
- Methods grouped by concern:
  - Core execution: initialize, execute, execute2Step
  - Configuration: setEnvironmentToStage/Prod, setLoggingEnabled
  - Fulfillment: setFulfillmentAttributes, purchaseFinalized
  - Session: setSessionId, getSessionId

## Entry Points

**SDK Initialization (Rokt Class):**

- Location: `src/Rokt.tsx`
- Triggers: Application startup or early in app lifecycle
- Responsibilities:
  - Detect New Architecture vs Old Architecture (lines 11-25)
  - Select appropriate native module implementation
  - Expose static API for initialization and execution
  - Validate native module availability

**Embedded Widget Component:**

- Location: `src/rokt-embedded-view.ts` (platform selector), `src/rokt-embedded-view.ios.tsx`, `src/rokt-embedded-view.android.tsx`
- Triggers: Application renders `<RoktEmbeddedView>` in JSX
- Responsibilities:
  - Create platform-appropriate component instance
  - Handle native events for dimension changes
  - Maintain component state for layout dimensions

**Public Exports:**

- Location: `src/index.tsx`
- Exports: Rokt, RoktEmbeddedView, RoktEventManager, RoktConfigBuilder, CacheConfig, interfaces

## Error Handling

**Strategy:** Error validation and exception throwing at SDK initialization; graceful null checks in event handlers.

**Patterns:**

- **Module Availability Check**: Lines 35-39 in `src/Rokt.tsx` throw if native module not linked
- **Architecture Detection**: Automatic fallback from New to Old Architecture (lines 11-32)
- **Event Handler Safety**: Optional chaining and null checks in event handlers (e.g., `src/rokt-embedded-view.android.tsx` lines 87-108)
- **Activity Availability**: Android module retries initialization if Activity null (see `android/src/main/java/com/rokt/reactnativesdk/RNRoktWidgetModuleImpl.kt` lines 306-337)
- **Type Safety**: TypeScript strict mode enabled in `tsconfig.json` ensures compile-time safety

## Cross-Cutting Concerns

**Logging:**

- Native implementations: `setLoggingEnabled(boolean)` method delegates to native Rokt SDK
- Android: Debug flag in RNRoktWidgetModuleImpl controls Log.d() calls
- iOS: Logging controlled via native Rokt SDK

**Validation:**

- JavaScript: TypeScript interfaces enforce type safety
- Native (Android): ReadableMap conversion with type filtering (map values must be String)
- Native (iOS): Standard Objective-C type coercion

**Authentication & Session Management:**

- Session ID support: `setSessionId(id)` and `getSessionId()` methods
- Purpose: Maintain consistent sessions across WebView and native integrations
- Implementation: Native SDK maintains session storage

**Environment Configuration:**

- Two-level environment: Stage (sandbox/testing) and Prod (production)
- Methods: `setEnvironmentToStage()`, `setEnvironmentToProd()`
- Android: Delegates to native Rokt.setEnvironment()
- iOS: Delegates to native Rokt SDK

**Platform Differences:**

- iOS: Uses native event emitter for height changes (ios.tsx lines 73-80)
- Android: Uses nativeEvent property in event objects (android.tsx lines 40-52)
- Both: Unified RoktEmbeddedView export via platform selector (rokt-embedded-view.ts)

---

_Architecture analysis: 2026-04-14_
