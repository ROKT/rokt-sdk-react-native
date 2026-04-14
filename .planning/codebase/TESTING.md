# Testing Patterns

**Analysis Date:** 2026-04-14

## Test Framework

**Runner:**

- Jest (primary test framework)
- Version: `^29.6.3` in sample app; `^27.5.1` in SDK dev dependencies
- Config: `RoktSampleApp/jest.config.js` (minimal preset: `react-native`)
- SDK (`Rokt.Widget/`) has no Jest config; no tests currently implemented

**Assertion Library:**

- Jest built-in assertions (no separate assertion library configured)
- React Test Renderer available for testing React components: `react-test-renderer@19.1.0`

**Run Commands:**

```bash
# From RoktSampleApp/ or Rokt.Widget/
npm test                 # Run all tests (currently no-op in SDK)
npm run test             # Same as above
```

**Note:** SDK test script shows: `"test": "echo \"Error: no test specified\" && exit 1"` — tests are not yet implemented.

## Test File Organization

**Location:**

- Test files co-located with source (pattern not yet established since no tests exist)
- Common pattern expected: `*.test.ts`, `*.test.tsx`, `*.spec.ts`, or `*.spec.tsx`
- Sample app appears to follow Jest defaults

**Naming:**

- Not yet established; typically `<module>.test.ts` or `<module>.spec.ts` format expected

**Structure:**

```
RoktSampleApp/
├── App.tsx             # Main component (untested)
├── utils/              # Utility functions (untested)
│   ├── text-utils.js
│   └── rokt-constants.js
└── __tests__/          # Convention location (not currently used)
    └── text-utils.test.js
```

## Test Structure

**No test files currently exist in the codebase.** This is a gap that should be addressed.

**Expected patterns based on codebase structure:**

**Unit Test Structure (expected):**

```typescript
describe("RoktEmbeddedView", () => {
  describe("height change handling", () => {
    it("should update state when height changed event fires", () => {
      // Test case for handleHeightChanged
    });
  });

  describe("margin change handling", () => {
    it("should update all margin values from native event", () => {
      // Test case for handleMarginChanged
    });
  });
});
```

**Component Test Setup (expected):**

```typescript
import React from 'react';
import TestRenderer from 'react-test-renderer';
import { RoktEmbeddedView } from '@rokt/react-native-sdk';

describe('RoktEmbeddedView', () => {
  it('should render with placeholder name', () => {
    const component = TestRenderer.create(
      <RoktEmbeddedView placeholderName="TestPlaceholder" />
    );
    expect(component.root).toBeDefined();
  });
});
```

## Mocking

**Framework:** Jest built-in mocking system

**Patterns:**

**Mock React Native modules:**

```typescript
// Pattern used in SDK for native module access
jest.mock("react-native", () => ({
  NativeModules: {
    RNRoktWidget: {
      initialize: jest.fn(),
      execute: jest.fn(),
    },
  },
}));
```

**Mock Native Event Emitter:**

```typescript
// For components using NativeEventEmitter
jest.mock("react-native", () => ({
  NativeEventEmitter: jest.fn(() => ({
    addListener: jest.fn(),
  })),
}));
```

**Mock child components:**

```typescript
// For testing RoktEmbeddedView in isolation
jest.mock("./RoktNativeWidgetNativeComponent", () => {
  return jest.fn(() => null);
});
```

**What to Mock:**

- Native modules: `NativeModules.RNRoktWidget`, `NativeModules.RoktEventManager`
- React Native APIs: `NativeEventEmitter`, `UIManager`, `Platform`
- Child native components: `RoktNativeWidgetNativeComponent`
- External libraries: Encryption libraries (`crypto-js`, `node-forge`) in sample app

**What NOT to Mock:**

- Core React Native components: `View`, `Text`, `StyleSheet` (use TestRenderer or Enzyme)
- Component lifecycle methods: Test actual behavior with TestRenderer
- Builder pattern methods: Test the actual object construction
- TypeScript types: No runtime mocking needed

## Fixtures and Factories

**Test Data:**
No test fixtures currently exist. Based on codebase patterns, fixtures should follow this approach:

```typescript
// fixtures/rokt-test-data.ts
export const createMockRoktConfig = (overrides = {}) => {
  return {
    colorMode: "light" as const,
    cacheConfig: {
      cacheDurationInSeconds: 90 * 60,
      cacheAttributes: { userId: "123" },
    },
    ...overrides,
  };
};

export const createMockAttributes = () => ({
  userId: "user123",
  email: "test@example.com",
  country: "US",
});
```

**Location:**

- Expected at: `__tests__/fixtures/` or `__mocks__/`
- Constants currently at: `RoktSampleApp/utils/rokt-constants.js` (can serve as test data)

## Coverage

**Requirements:** No coverage threshold enforced; no coverage reporting configured

**View Coverage:**

```bash
npm test -- --coverage        # Generate coverage (if tests exist)
npx jest --coverage           # Alternative command
```

**Target:** Coverage targets should be defined for:

- SDK public API: 100% (critical interfaces like `Rokt`, `RoktEmbeddedView`)
- Native module integration: 100% (error handling, fallbacks)
- Sample app: 70%+ (non-critical demo code)

## Test Types

**Unit Tests:**

- Scope: Individual functions and methods (text-utils, rokt-constants)
- Approach: Test utility functions in isolation
- Example targets:
  - `isEmpty()`, `isNotEmpty()`, `isValidJson()` from `text-utils.js`
  - Builder pattern: `RoktConfigBuilder.withColorMode()`, `.withCacheConfig()`, `.build()`
  - Event handlers: `handleHeightChanged()`, `handleMarginChanged()`

**Integration Tests:**

- Scope: SDK-Native bridge communication, event emission
- Approach: Test `Rokt` static methods with mocked native modules
- Example targets:
  - `Rokt.initialize()` → calls correct native method
  - `Rokt.execute()` → passes attributes and placeholders correctly
  - Event listeners in `RoktEmbeddedView` → respond to native events
  - Session ID lifecycle: `setSessionId()` + `getSessionId()`

**Component Tests:**

- Scope: React component rendering and lifecycle
- Approach: Use `react-test-renderer` or React Native Testing Library
- Example targets:
  - `RoktEmbeddedView` renders with placeholder
  - Height changes trigger state updates
  - Margin changes update all four properties
  - Component cleanup on unmount (subscription removal)
  - Error boundary behavior (Android try-catch render)

**E2E Tests:**

- Framework: Not currently configured
- Status: Detox or similar could be added for native E2E testing
- Recommendation: Configure for sample app to verify actual native module integration

## Common Patterns

**Async Testing:**

```typescript
// For testing native module callbacks
describe("Event listeners", () => {
  it("should handle async events from native", async () => {
    const listener = jest.fn();
    eventManagerEmitter.addListener("WidgetHeightChanges", listener);

    // Simulate native event
    eventManagerEmitter.emit("WidgetHeightChanges", {
      selectedPlacement: "Location1",
      height: "100",
    });

    // Verify listener was called
    expect(listener).toHaveBeenCalledWith({
      selectedPlacement: "Location1",
      height: "100",
    });
  });
});
```

**Error Testing:**

```typescript
// Testing initialization error
describe("Rokt initialization", () => {
  it("should throw error when native module unavailable", () => {
    jest.resetModules();
    jest.mock("react-native", () => ({
      NativeModules: { RNRoktWidget: null },
      UIManager: null,
    }));

    expect(() => {
      require("./Rokt");
    }).toThrow("Rokt Native Module is not available");
  });
});
```

**Render Testing (Android Error Boundary):**

```typescript
// Testing the try-catch in RoktEmbeddedView.android.tsx render()
describe('RoktEmbeddedView error handling', () => {
  it('should return null when rendering fails', () => {
    jest.mock('./RoktNativeWidgetNativeComponent', () => {
      throw new Error('Native component error');
    });

    const component = TestRenderer.create(
      <RoktEmbeddedView placeholderName="test" />
    );

    expect(component.root.findByType(RoktEmbeddedView).instance.render())
      .toBeNull();
  });
});
```

## Test Coverage Gaps

**Currently Untested Areas:**

**Critical (Highest Priority):**

- `Rokt.tsx`: All static methods (initialize, execute, execute2Step, purchaseFinalized, etc.)
- `RoktEmbeddedView` (both iOS and Android): Component lifecycle, event handling, state updates
- Native module bridge: TurboModule vs old architecture detection
- Error handling: Native module unavailability, event listener cleanup

**Important (Medium Priority):**

- `RoktConfigBuilder`: Builder pattern methods and build() finalization
- `CacheConfig`: Constructor and readonly property behavior
- Utility functions: `isEmpty()`, `isNotEmpty()`, `isValidJson()`
- Platform-specific behavior: iOS vs Android implementations divergence

**Nice to Have (Low Priority):**

- Sample app UI integration: button clicks, form input handling
- Encryption flow: RSA encryption with node-forge
- Event emission: RoktCallback, RoktEvents, FirstPositiveResponse

## Testing Best Practices

**What to Test:**

1. Public API contracts (method signatures, return types)
2. Error conditions (null checks, invalid inputs)
3. State transitions (component state changes on events)
4. Native integration (module availability, method calls)
5. Event handling (listeners added, cleaned up)

**Test File Organization:**

- Keep tests near implementation: `Component.tsx` + `Component.test.tsx` in same directory
- Group related tests with `describe` blocks
- Use descriptive `it()` messages: "should X when Y" not "test"

**Mocking Strategy:**

- Mock at boundaries: Native modules, external APIs, child components
- Don't mock your own code; test actual behavior
- Reset mocks between tests: `jest.clearAllMocks()`

**Setup/Teardown:**

```typescript
beforeEach(() => {
  jest.clearAllMocks();
  // Reset state before each test
});

afterEach(() => {
  // Cleanup: unsubscribe from listeners, etc.
});
```

---

_Testing analysis: 2026-04-14_

**Note:** The SDK currently has no tests despite Jest being configured. This is a significant gap requiring immediate attention. Start with unit tests for utility functions and builder pattern, then add integration tests for the native bridge and component tests for `RoktEmbeddedView`.
