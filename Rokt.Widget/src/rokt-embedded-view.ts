// rokt-embedded-view.ts
import { Platform } from "react-native";

// Import both implementations
import { RoktEmbeddedView as RoktEmbeddedViewIOS } from "./rokt-embedded-view.ios";
import { RoktEmbeddedView as RoktEmbeddedViewAndroid } from "./rokt-embedded-view.android";

// Export types
export type { RoktEmbeddedViewProps } from "./rokt-embedded-view.ios";

// Export the appropriate component based on platform
export const RoktEmbeddedView =
  Platform.OS === "ios" ? RoktEmbeddedViewIOS : RoktEmbeddedViewAndroid;

// Default export
export default RoktEmbeddedView;
