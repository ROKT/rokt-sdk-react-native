import { ConfigPlugin, withDangerousMod } from "@expo/config-plugins";
import * as fs from "fs";
import * as path from "path";

/**
 * Pods that require dynamic framework linking to avoid module map
 * redefinition errors with React Native's new architecture module system.
 *
 * Rokt SDK 5.0 ships as source-based pods. When linked statically (the
 * CocoaPods default), their Swift module maps collide with React Native's
 * `install_modules_dependencies` header search paths, producing
 * "Redefinition of module 'X'" build errors. Dynamic linking isolates
 * each module into its own framework bundle, eliminating the conflict.
 */
const DYNAMIC_FRAMEWORK_PODS = [
  "Rokt-Widget",
  "RoktContracts",
  "RoktUXHelper",
  "DcuiSchema",
];

/**
 * Injects a `pre_install` hook into the Podfile that forces dynamic
 * framework linking for Rokt SDK pods.
 */
const withRoktPodfile: ConfigPlugin = (config) => {
  return withDangerousMod(config, [
    "ios",
    (config) => {
      const podfilePath = path.join(
        config.modRequest.platformProjectRoot,
        "Podfile",
      );

      if (!fs.existsSync(podfilePath)) {
        return config;
      }

      let podfileContent = fs.readFileSync(podfilePath, "utf-8");

      // Skip if already configured
      if (podfileContent.includes("Rokt-Widget")) {
        return config;
      }

      const podConditions = DYNAMIC_FRAMEWORK_PODS.map(
        (pod) => `pod.name == '${pod}'`,
      ).join(" || ");

      const preInstallHook = `
# Rokt SDK dynamic framework linking (added by @rokt/react-native-sdk expo plugin)
pre_install do |installer|
  installer.pod_targets.each do |pod|
    if ${podConditions}
      def pod.build_type;
        Pod::BuildType.new(:linkage => :dynamic, :packaging => :framework)
      end
    end
  end
end
`;

      // Insert after platform declaration
      const platformRegex = /platform :ios.*\n/;
      if (platformRegex.test(podfileContent)) {
        podfileContent = podfileContent.replace(
          platformRegex,
          `$&${preInstallHook}`,
        );
      }

      fs.writeFileSync(podfilePath, podfileContent, "utf-8");

      return config;
    },
  ]);
};

/**
 * Expo Config Plugin for Rokt React Native SDK
 *
 * Configures the iOS Podfile for Rokt SDK 5.0 compatibility:
 * - Injects pre_install hook for dynamic framework linking of Rokt pods
 *
 * Android requires no modifications — autolinking and Maven Central handle
 * package registration and dependency resolution automatically.
 */
const withRoktSDK: ConfigPlugin = (config) => {
  config = withRoktPodfile(config);
  return config;
};

export default withRoktSDK;
