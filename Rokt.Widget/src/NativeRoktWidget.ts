/**
 * NativeRoktWidget.ts
 *
 * Licensed under the Rokt Software Development Kit (SDK) Terms of Use
 * Version 2.0 (the "License");
 *
 * You may not use this file except in compliance with the License.
 *
 * You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
 */

import type { TurboModule } from "react-native/Libraries/TurboModule/RCTExport";
import { TurboModuleRegistry } from "react-native";

type ColorMode = string;

type CacheConfig = {
  readonly cacheDurationInSeconds?: number;
  readonly cacheAttributes?: { [key: string]: string };
};

type RoktConfigType = {
  readonly colorMode?: ColorMode;
  readonly cacheConfig?: CacheConfig;
};

export interface Spec extends TurboModule {
  // Core methods
  initialize(roktTagId: string, appVersion: string): void;
  initializeWithFontFiles(
    roktTagId: string,
    appVersion: string,
    fontsMap: { [key: string]: string },
  ): void;
  execute(
    viewName: string,
    attributes: { [key: string]: string },
    placeholders: { [key: string]: number | null },
  ): void;
  executeWithConfig(
    viewName: string,
    attributes: { [key: string]: string },
    placeholders: { [key: string]: number | null },
    roktConfig: RoktConfigType,
  ): void;
  execute2Step(
    viewName: string,
    attributes: { [key: string]: string },
    placeholders: { [key: string]: number | null },
  ): void;
  execute2StepWithConfig(
    viewName: string,
    attributes: { [key: string]: string },
    placeholders: { [key: string]: number | null },
    roktConfig: RoktConfigType,
  ): void;
  purchaseFinalized(
    placementId: string,
    catalogItemId: string,
    success: boolean,
  ): void;

  // Additional methods
  setFulfillmentAttributes(attributes: { [key: string]: string }): void;
  setEnvironmentToStage(): void;
  setEnvironmentToProd(): void;
  setLoggingEnabled(enabled: boolean): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>("RNRoktWidget");
