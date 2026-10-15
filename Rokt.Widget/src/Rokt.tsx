import "react-native";
import { NativeModules, UIManager } from "react-native";
import type { Spec as RoktNativeInterface } from "./NativeRoktWidget";
// Import the default export for direct access
import NativeRoktDefault from "./NativeRoktWidget";

// Check if the New Architecture is enabled
// and select the appropriate Native Module
let RNRoktWidget: RoktNativeInterface;

const isNewArchitecture = (() => {
  // Check if Fabric renderer is enabled
  const hasFabricUIManager =
    UIManager &&
    typeof UIManager.hasViewManagerConfig === "function" &&
    UIManager.hasViewManagerConfig("RCTView");

  if (hasFabricUIManager) {
    return true;
  }

  // Fallback: check TurboModule presence
  const turboModuleCheck = NativeModules.RNRoktWidget == null;
  return turboModuleCheck;
})();

if (isNewArchitecture) {
  // Use the imported default export
  RNRoktWidget = NativeRoktDefault;
} else {
  RNRoktWidget = NativeModules.RNRoktWidget;
}

// Ensure the module is available
if (!RNRoktWidget) {
  throw new Error(
    "Rokt Native Module is not available. Did you forget to link the library?",
  );
}

/** Names are preferred; numeric React tags remain supported for existing integrations. */
export type RoktPlaceholders = string[] | Record<string, number | null>;
export type RoktAttributeValue = string | number | boolean;

function toNativePlaceholders(
  placeholders: RoktPlaceholders,
): Record<string, number> {
  const result: Record<string, number> = {};
  if (placeholders == null) return result;
  const names = Array.isArray(placeholders)
    ? placeholders
    : Object.keys(placeholders);
  for (const name of names) {
    // iOS codegen drops null-valued dictionary entries; React tags are always positive.
    Object.defineProperty(result, name, {
      value: Array.isArray(placeholders) ? 0 : (placeholders[name] ?? 0),
      enumerable: true,
      configurable: true,
      writable: true,
    });
  }
  return result;
}

function toNativeAttributes(
  attributes: Record<string, RoktAttributeValue>,
): Record<string, string> {
  const result: Record<string, string> = {};
  for (const name of Object.keys(attributes ?? {})) {
    const value = attributes[name];
    if (
      typeof value === "string" ||
      typeof value === "number" ||
      typeof value === "boolean"
    ) {
      Object.defineProperty(result, name, {
        value: String(value),
        enumerable: true,
        configurable: true,
        writable: true,
      });
    }
  }
  return result;
}

export abstract class Rokt {
  /**
   * Initialize the Rokt SDK. Call once, early (e.g. on app start), before selecting
   * placements.
   *
   * @param roktTagId - Your Rokt tag/account id
   * @param appVersion - Your app's version string
   * @param fontFilesMap - Optional map of font PostScript name to local font file path, to supply your own fonts used in your layouts
   */
  public static initialize(
    roktTagId: string,
    appVersion: string,
    fontFilesMap?: Record<string, string>,
  ): void {
    if (fontFilesMap) {
      RNRoktWidget.initializeWithFontFiles(roktTagId, appVersion, fontFilesMap);
    } else {
      RNRoktWidget.initialize(roktTagId, appVersion);
    }
  }

  /**
   * Select and display Rokt placements (overlay or embedded) for an identifier.
   *
   * @param identifier - The placement identifier configured in Rokt
   * @param attributes - Key-value attributes (e.g. email, country) for targeting
   * @param placeholders - Embedded placeholder names (preferred) or legacy React tags. Names wait up to two seconds for mounting. Omit for overlay-only.
   * @param roktConfig - Optional configuration (color mode, caching)
   */
  public static selectPlacements(
    identifier: string,
    attributes: Record<string, RoktAttributeValue>,
    placeholders: RoktPlaceholders = [],
    roktConfig?: IRoktConfig,
  ): void {
    const nativeAttributes = toNativeAttributes(attributes);
    const nativePlaceholders = toNativePlaceholders(placeholders);
    if (roktConfig) {
      RNRoktWidget.selectPlacementsWithConfig(
        identifier,
        nativeAttributes,
        nativePlaceholders,
        roktConfig,
      );
    } else {
      RNRoktWidget.selectPlacements(
        identifier,
        nativeAttributes,
        nativePlaceholders,
      );
    }
  }

  /**
   * Select shoppable ads for a given identifier.
   *
   * Shoppable ads use a full-screen overlay (no embedded placeholders).
   * Payment extension registration must be done in native AppDelegate code.
   *
   * @param identifier - The identifier for the shoppable ads placement
   * @param attributes - Key-value attributes for the placement
   * @param roktConfig - Optional configuration for the placement
   */
  public static selectShoppableAds(
    identifier: string,
    attributes: Record<string, RoktAttributeValue>,
    roktConfig?: IRoktConfig,
  ): void {
    const nativeAttributes = toNativeAttributes(attributes);
    if (roktConfig) {
      RNRoktWidget.selectShoppableAdsWithConfig(
        identifier,
        nativeAttributes,
        roktConfig,
      );
    } else {
      RNRoktWidget.selectShoppableAds(identifier, nativeAttributes);
    }
  }

  /**
   * Close the loop on a Rokt in-placement instant purchase (Shoppable Ads).
   *
   * Call this ONLY in response to a `CartItemInstantPurchase` event, after you have
   * processed that item's payment. Pass the `placementId` and `catalogItemId` taken
   * from that event.
   *
   * IMPORTANT: This is NOT a generic order-confirmation or checkout hook. Do not call
   * it on your order-confirmation page after a normal purchase — the native SDK no-ops
   * unless a Rokt instant purchase is currently open.
   *
   * @param placementId - The Rokt placement/layout id from the `CartItemInstantPurchase` event (NOT your order id)
   * @param catalogItemId - The catalog item id from the `CartItemInstantPurchase` event
   * @param success - Whether your payment processing for the item succeeded
   */
  public static purchaseFinalized(
    placementId: string,
    catalogItemId: string,
    success: boolean,
  ): void {
    RNRoktWidget.purchaseFinalized(placementId, catalogItemId, success);
  }

  public static setEnvironmentToStage(): void {
    RNRoktWidget.setEnvironmentToStage();
  }

  public static setEnvironmentToProd(): void {
    RNRoktWidget.setEnvironmentToProd();
  }

  /**
   * Set a custom session ID for the Rokt SDK.
   *
   * @param sessionId - The session ID to set. Must be a non-empty string.
   */
  public static setSessionId(sessionId: string): void {
    RNRoktWidget.setSessionId(sessionId);
  }

  /**
   * Get the current session ID from the Rokt SDK.
   *
   * @returns The current session ID, or null if not set.
   */
  public static getSessionId(): string | null {
    return RNRoktWidget.getSessionId();
  }

  /**
   * Route all Rokt SDK requests through a custom CNAME / first-party domain.
   *
   * Must be called **before** {@link Rokt.initialize}. The SDK uses only the
   * scheme, host, and port — any path, query, or fragment is ignored.
   * Non-HTTPS URLs or URLs with a missing/empty host are rejected with a warning.
   *
   * @param url - HTTPS URL whose host is the partner's CNAME domain.
   */
  public static setCustomBaseURL(url: string): void {
    RNRoktWidget.setCustomBaseURL(url);
  }

  /**
   * Register the host app's bare custom URL scheme used for built-in PayPal
   * device-pay redirects.
   *
   * The scheme must also be declared in the iOS `Info.plist` under
   * `CFBundleURLTypes`/`CFBundleURLSchemes`. Pass `null` to clear the scheme.
   *
   * iOS only — no-op on Android, where the SDK handles PayPal redirects
   * automatically via a self-registered manifest activity scoped to the
   * host app's own package name, so no host-app wiring is needed there.
   *
   * @param scheme - Bare scheme string (e.g. `"myapp"`, no `://`), or `null` to clear.
   */
  public static setPaymentCallbackURLScheme(scheme: string | null): void {
    RNRoktWidget.setPaymentCallbackURLScheme(scheme);
  }

  /**
   * Forward an incoming deep-link URL to the Rokt SDK so a redirect-based
   * payment method (built-in PayPal, or a registered payment extension) can
   * resume. Wire this from React Native's `Linking` listener.
   *
   * iOS only — no-op on Android (see {@link Rokt.setPaymentCallbackURLScheme}).
   *
   * @param url - The URL received by the host app from `Linking`.
   */
  public static handleURLCallback(url: string): void {
    RNRoktWidget.handleURLCallback(url);
  }
}

declare module "react-native" {
  interface NativeModulesStatic {
    RNRoktWidget: RoktNativeInterface;
  }
}

// Define the interface that matches the native module for cleaner code
export interface IRoktConfig {
  readonly colorMode?: ColorMode;
  readonly cacheConfig?: CacheConfig;
}

/**
 * Cache configuration for Rokt SDK
 */
export class CacheConfig {
  /**
   * @param cacheDurationInSeconds - The duration in seconds for which the Rokt SDK should cache the experience. Default is 90 minutes
   * @param cacheAttributes - optional attributes to be used as cache key. If null, all the attributes will be used as the cache key
   */
  constructor(
    public readonly cacheDurationInSeconds?: number,
    public readonly cacheAttributes?: Record<string, string>,
  ) {}
}

class RoktConfig implements IRoktConfig {
  constructor(roktConfig: RoktConfig) {
    Object.assign(this, roktConfig);
  }
}

export class RoktConfigBuilder implements Partial<IRoktConfig> {
  readonly colorMode?: ColorMode;
  readonly cacheConfig?: CacheConfig;

  public withColorMode(
    value: ColorMode,
  ): this & Pick<IRoktConfig, "colorMode"> {
    return Object.assign(this, { colorMode: value });
  }

  public withCacheConfig(
    value: CacheConfig,
  ): this & Pick<IRoktConfig, "cacheConfig"> {
    return Object.assign(this, { cacheConfig: value });
  }

  public build(this: IRoktConfig) {
    return new RoktConfig(this);
  }
}

export type ColorMode = "light" | "dark" | "system";
