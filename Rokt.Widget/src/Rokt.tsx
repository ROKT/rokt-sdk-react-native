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

export abstract class Rokt {
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

  public static execute(
    viewName: string,
    attributes: Record<string, string>,
    placeholders: Record<string, number | null>,
    roktConfig?: IRoktConfig,
  ): void {
    if (roktConfig) {
      RNRoktWidget.executeWithConfig(
        viewName,
        attributes,
        placeholders,
        roktConfig,
      );
    } else {
      RNRoktWidget.execute(viewName, attributes, placeholders);
    }
  }

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
