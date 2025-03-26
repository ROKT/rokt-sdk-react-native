import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { IRoktConfig } from './Rokt';

export interface Spec extends TurboModule {
  // Core methods
  initialize(roktTagId: string, appVersion: string): void;
  initializeWithFontFiles(roktTagId: string, appVersion: string, fontsMap: Record<string, string>): void;
  execute(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>): void;
  executeWithConfig(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig: IRoktConfig): void;
  execute2Step(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>): void;
  execute2StepWithConfig(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig: IRoktConfig): void;
  
  // Additional methods
  setFulfillmentAttributes(attributes: Record<string, string>): void;
  setEnvironmentToStage(): void;
  setEnvironmentToProd(): void;
  setLoggingEnabled(enabled: boolean): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNRoktWidget'); 