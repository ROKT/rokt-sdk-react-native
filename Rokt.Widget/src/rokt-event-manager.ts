import { NativeModules } from "react-native";
import NativeRoktEventManager from "./NativeRoktEventManager";

// Prefer codegen registration so bridgeless hosts need no legacy module interop.
export const RoktEventManager =
  NativeRoktEventManager ??
  (NativeModules.RoktEventManager as typeof NativeRoktEventManager) ??
  null;
