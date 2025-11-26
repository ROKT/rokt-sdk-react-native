import { ConfigPlugin } from "@expo/config-plugins";

/**
 * Expo Config Plugin for Rokt React Native SDK
 *
 * This plugin configures your Expo project to use the Rokt SDK.
 *
 * Current behavior:
 * - Android: No modifications needed - autolinking handles package registration
 *   and the Rokt native SDK is available via Maven Central
 * - iOS: No modifications needed - the podspec declares the Rokt-Widget dependency
 *   which is resolved automatically via CocoaPods
 *
 * This plugin is kept as a placeholder for potential future configuration needs
 * and to provide a consistent integration experience for Expo users.
 */
const withRoktSDK: ConfigPlugin = (config) => {
  return config;
};

export default withRoktSDK;
