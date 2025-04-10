import type { TurboModule } from 'react-native/Libraries/TurboModule/RCTExport';
import { TurboModuleRegistry } from 'react-native';
// Remove the IRoktConfig import
// import { IRoktConfig } from './Rokt';

// Define the ColorMode type inline
type ColorMode = "light" | "dark" | "system";

// Define CacheConfig inline
type CacheConfig = {
  readonly cacheDurationInSeconds?: number;
  readonly cacheAttributes?: {[key: string]: string};
};

// Define RoktConfig inline
type RoktConfigType = {
  readonly colorMode?: ColorMode;
  readonly cacheConfig?: CacheConfig;
};

export interface Spec extends TurboModule {
    // Core methods
    initialize(roktTagId: string, appVersion: string): void;
    initializeWithFontFiles(roktTagId: string, appVersion: string, fontsMap: {[key: string]: string}): void;
    execute(viewName: string, attributes: {[key: string]: string}, placeholders: {[key: string]: number | null}): void;
    executeWithConfig(viewName: string, attributes: {[key: string]: string}, placeholders: {[key: string]: number | null}, roktConfig: RoktConfigType): void;
    execute2Step(viewName: string, attributes: {[key: string]: string}, placeholders: {[key: string]: number | null}): void;
    execute2StepWithConfig(viewName: string, attributes: {[key: string]: string}, placeholders: {[key: string]: number | null}, roktConfig: RoktConfigType): void;
    purchaseFinalized(placementId: string, catalogItemId: string, success: boolean): void;

    // Additional methods
    setFulfillmentAttributes(attributes: {[key: string]: string}): void;
    setEnvironmentToStage(): void;
    setEnvironmentToProd(): void;
    setLoggingEnabled(enabled: boolean): void;
}


// Also log what's available in NativeModules for comparison
export default TurboModuleRegistry.getEnforcing<Spec>('RNRoktWidget');