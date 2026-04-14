# Coding Conventions

**Analysis Date:** 2026-04-14

## Naming Patterns

**Files:**

- SDK source: `PascalCase.tsx` for React components and exported classes (e.g., `Rokt.tsx`, `RoktEmbeddedView`)
- Native modules: `PascalCase.ts` for TypeScript modules (e.g., `NativeRoktWidget.ts`)
- Platform-specific files: Use `.android` and `.ios` extensions with platform suffix before extension (e.g., `rokt-embedded-view.android.tsx`, `rokt-embedded-view.ios.tsx`)
- Barrel/index files: `index.tsx` or `index.ts` for module exports
- Utilities: `kebab-case.js` for helper files (e.g., `text-utils.js`, `rokt-constants.js`)

**Functions:**

- Static utility functions: `camelCase` with no prefix (e.g., `isEmpty()`, `isNotEmpty()`, `isValidJson()`)
- Instance methods: `camelCase` (e.g., `initialize()`, `execute()`, `purchaseFinalized()`)
- Event handlers: `camelCase` with `handle` prefix or context-specific name (e.g., `handleHeightChanged()`, `handleMarginChanged()`)
- Private methods: `camelCase` with `private` access modifier (e.g., `private handleHeightChanged = ...`)
- Builder pattern methods: `withXxx()` naming convention (e.g., `withColorMode()`, `withCacheConfig()`)
- Static class methods: `camelCase` without instance requirement (e.g., `Rokt.initialize()`, `Rokt.execute()`)

**Variables:**

- Local/state variables: `camelCase` (e.g., `tagId`, `viewName`, `placeholderName`)
- Constants: `UPPER_SNAKE_CASE` for module-level constants (e.g., `DEFAULT_TAG_ID`, `ENCRYPTION_KEY_ID_STAGE`)
- React state: `camelCase` properties in state objects (e.g., `this.state.height`, `this.state.marginTop`)
- Props interfaces: `camelCase` for prop names (e.g., `placeholderName`, `onWidgetHeightChanged`)
- Type aliases: `camelCase` for type names (e.g., `ColorMode`)

**Types:**

- Interfaces: `PascalCase` with `I` prefix for interfaces representing contracts or APIs (e.g., `IRoktConfig`)
- Interfaces without prefix for component props and event types (e.g., `RoktEmbeddedViewProps`, `HeightChangedEvent`)
- Type unions: `PascalCase` (e.g., `ColorMode = "light" | "dark" | "system"`)
- Classes: `PascalCase` for all exported classes (e.g., `Rokt`, `CacheConfig`, `RoktConfigBuilder`)
- Readonly properties: Use `readonly` keyword for immutable properties

## Code Style

**Formatting:**

- Prettier with React Native preset is configured in `RoktSampleApp/.prettierrc.js`
- Key settings:
  - Single quotes: `'` (not double quotes)
  - Arrow function parens: Omit parens for single arguments (`avoid`)
  - Bracket same line: `true`
  - Bracket spacing: `false` (e.g., `{foo}` not `{ foo }`)
  - Trailing commas: Always (`all`)
- SDK package (`Rokt.Widget/`) does not have explicit Prettier config; uses ESLint defaults

**Linting:**

- SDK uses ESLint with TypeScript support (`Rokt.Widget/.eslintrc.cjs`):
  - Config: `eslint:recommended` + `@typescript-eslint/recommended` + `@typescript-eslint/recommended-requiring-type-checking`
  - Parser: `@typescript-eslint/parser` with full type checking enabled
  - Ignores: `dist/`, `.eslintrc.cjs`, `app.plugin.js`, `plugin/build`
- Sample app uses React Native ESLint config: `@react-native` extended config
- Run with: `npm run lint` from respective directories

## Import Organization

**Order:**

1. React/React Native core imports
2. React Native component imports (`import { ... } from 'react-native'`)
3. Third-party library imports
4. Project-relative imports (using `./` or `../`)

**Example from codebase:**

```typescript
import React, { Component } from "react";
import {
  EmitterSubscription,
  findNodeHandle,
  NativeEventEmitter,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from "react-native";
import CheckBox from "@react-native-community/checkbox";
import Toast from "react-native-toast-message";
import { isEmpty, isNotEmpty, isValidJson } from "./utils/text-utils";
import { DEFAULT_ATTRIBUTES, DEFAULT_TAG_ID } from "./utils/rokt-constants";
```

**Path Aliases:**

- No path aliases configured; uses relative paths
- Prefer explicit relative imports over default exports when sharing between modules

## Error Handling

**Patterns:**

- Throw errors for initialization failures:
  ```typescript
  if (!RNRoktWidget) {
    throw new Error(
      "Rokt Native Module is not available. Did you forget to link the library?",
    );
  }
  ```
- Use try-catch at component render boundaries:
  ```typescript
  override render() {
    try {
      return <RoktNativeWidgetNativeComponent ... />;
    } catch (error) {
      console.error("[ROKT] Error rendering RoktEmbeddedView:", error);
      return null;
    }
  }
  ```
- Render `null` on error in component rendering (Android implementation)
- No custom error classes; use standard JavaScript `Error`
- Validate native module availability at startup

## Logging

**Framework:** Native `console` object (no logging library)

**Patterns:**

- Error logs use prefixed format: `console.error("[ROKT] message")`
- Info logs use standard console: `console.log("message")`
- Warnings use console: `console.log("Error parsing JSON " + e)` or similar
- No structured logging; strings are concatenated
- Logging is optional and can be toggled at runtime via `Rokt.setLoggingEnabled()`

## Comments

**When to Comment:**

- JSDoc comments for public methods with meaningful details (see below)
- License headers: Include at top of sensitive files (e.g., `rokt-embedded-view.ios.tsx`)
- Inline comments for non-obvious logic: "Check if Fabric renderer is enabled"
- Comment sections separating logical groups (e.g., "// Core methods")

**JSDoc/TSDoc:**

- Public SDK methods documented with JSDoc blocks:
  ```typescript
  /**
   * Set the session id to use for the next execute call.
   *
   * This is useful for cases where you have a session id from a non-native integration,
   * e.g. WebView, and you want the session to be consistent across integrations.
   *
   * @remarks Empty strings are ignored and will not update the session.
   *
   * @param sessionId - The session id to be set. Must be a non-empty string.
   */
  public static setSessionId(sessionId: string): void {
    RNRoktWidget.setSessionId(sessionId);
  }
  ```
- Include `@param`, `@returns` tags for public APIs
- Use `@remarks` for additional context

## Function Design

**Size:** Functions are kept small and focused:

- SDK proxy methods: 1-10 lines (e.g., `initialize()`, `execute()`)
- Event handlers: 3-8 lines (e.g., `handleHeightChanged()`)
- State-heavy components: 40-140 lines (e.g., `RoktEmbeddedView` classes)

**Parameters:**

- Use typed parameters with explicit types (no `any`)
- Multiple parameters passed as `Record<string, T>` for maps:
  ```typescript
  public static execute(
    viewName: string,
    attributes: Record<string, string>,
    placeholders: Record<string, number | null>,
  ): void
  ```
- Optional parameters use `?` modifier in interfaces/types
- Builder pattern for complex configs: `RoktConfigBuilder` example

**Return Values:**

- Static utility methods return typed values (no implicit `undefined`)
- Methods with conditional returns use union types: `string | null`
- Render methods return `JSX.Element | null`
- Event listeners return `void`

## Module Design

**Exports:**

- Barrel file pattern: `index.tsx` re-exports public API
- Named exports for interfaces, types, and classes
- Default export for components: `export default RoktEmbeddedView`
- Type-only exports: `export type { IRoktConfig, ColorMode }`
- Separate type and value exports in barrel files

**Barrel Files:**

- `Rokt.Widget/src/index.tsx`: Main SDK entry point exporting:
  - `RoktEmbeddedView` (component)
  - `Rokt` (static API class)
  - `RoktEventManager` (native module reference)
  - `RoktConfigBuilder` (builder class)
  - `CacheConfig` (config class)
  - Types: `IRoktConfig`, `ColorMode`
- `rokt-embedded-view.ts`: Platform-specific selector exporting component and types
- No index.ts files in subdirectories; direct imports preferred

## Class Design

**Abstract Classes:**

- `Rokt` is declared `abstract` and contains only static methods (factory/singleton pattern)
- Cannot be instantiated; serves as namespace for SDK operations
- All methods are `public static`

**Builder Pattern:**

- `RoktConfigBuilder` implements builder for complex config objects
- Methods return `this & Pick<IRoktConfig, "fieldName">` for type safety
- `build()` method finalizes configuration and returns `RoktConfig` instance

**Readonly Properties:**

- Constructor parameters with `readonly` modifier in `CacheConfig`:
  ```typescript
  constructor(
    public readonly cacheDurationInSeconds?: number,
    public readonly cacheAttributes?: Record<string, string>,
  ) {}
  ```

---

_Convention analysis: 2026-04-14_
