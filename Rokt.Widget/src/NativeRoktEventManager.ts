import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";

// iOS-only emitter. Android emits through RCTDeviceEventEmitter.
export interface Spec extends TurboModule {
  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.get<Spec>("RoktEventManager");
