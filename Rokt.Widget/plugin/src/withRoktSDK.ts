import { ConfigPlugin, withDangerousMod } from "@expo/config-plugins";
import * as fs from "fs";
import * as path from "path";

export type RoktPluginProps = {
  /**
   * How iOS gets the Rokt SDK. "spm", the default, links it into the app as a Swift package.
   * "cocoapods" installs it as pods instead, and is deprecated.
   */
  iosDependencyManager?: "spm" | "cocoapods";
  /** Exact Rokt iOS SDK version in Swift Package Manager mode. Defaults to the tested version. */
  iosSdkVersion?: string;
  /** Optional Rokt packages in Swift Package Manager mode, such as "RoktPaymentExtension". */
  iosSpmPackages?: string[];
};

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

const SETTINGS_START =
  "# Rokt settings (added by @rokt/react-native-sdk expo plugin)";
const SETTINGS_END = "# end of Rokt settings";

// Values are written into the Podfile as Ruby string literals, so they must not be able to end one.
const VERSION_PATTERN = /^[0-9A-Za-z.+-]+$/;
const PACKAGE_PATTERN = /^[A-Za-z0-9._+-]+$/;

function rubyString(value: string, pattern: RegExp, what: string): string {
  if (typeof value !== "string" || !pattern.test(value)) {
    throw new Error(
      `[Rokt] Invalid ${what} in the @rokt/react-native-sdk plugin options: ${JSON.stringify(value)}`,
    );
  }
  return `'${value}'`;
}

function settingsLines(props: RoktPluginProps): string[] {
  const lines: string[] = [];
  if (props.iosSdkVersion !== undefined) {
    lines.push(
      `$RNRoktSPMVersion = ${rubyString(props.iosSdkVersion, VERSION_PATTERN, "iosSdkVersion")}`,
    );
  }
  if (props.iosSpmPackages !== undefined) {
    if (!Array.isArray(props.iosSpmPackages)) {
      throw new Error(
        "[Rokt] iosSpmPackages in the @rokt/react-native-sdk plugin options must be an array of package names",
      );
    }
    const names = props.iosSpmPackages.map((name) =>
      rubyString(name, PACKAGE_PATTERN, "iosSpmPackages entry"),
    );
    lines.push(`$RNRoktSPMPackages = [${names.join(", ")}]`);
  }
  return lines;
}

/**
 * Writes the settings block before the first `target`, which evaluates the podspec, or replaces the
 * block a previous run wrote, so a re-run picks up changed options.
 */
function setSettings(podfile: string, lines: string[]): string {
  const block = [SETTINGS_START, ...lines, SETTINGS_END].join("\n");
  const start = podfile.indexOf(SETTINGS_START);
  if (start !== -1) {
    const end = podfile.indexOf(SETTINGS_END, start);
    if (end === -1) {
      throw new Error(
        `[Rokt] ios/Podfile has "${SETTINGS_START}" but not "${SETTINGS_END}". Run npx expo prebuild --clean.`,
      );
    }
    return `${podfile.slice(0, start)}${block}${podfile.slice(end + SETTINGS_END.length)}`;
  }
  const target = /^target /m.exec(podfile);
  if (!target) {
    throw new Error("[Rokt] ios/Podfile has no target block");
  }
  return `${podfile.slice(0, target.index)}${block}\n\n${podfile.slice(target.index)}`;
}

function addDynamicFrameworkHook(podfile: string): string {
  // Skip if already configured
  if (podfile.includes("Rokt-Widget")) {
    return podfile;
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
  if (platformRegex.test(podfile)) {
    return podfile.replace(platformRegex, `$&${preInstallHook}`);
  }
  return podfile;
}

const OPTIONS: Record<keyof RoktPluginProps, true> = {
  iosDependencyManager: true,
  iosSdkVersion: true,
  iosSpmPackages: true,
};

/**
 * Applies the plugin's changes to the contents of ios/Podfile. Running it again gives the same
 * result.
 */
export function applyRoktPodfileMods(
  podfile: string,
  props: RoktPluginProps = {},
): string {
  const unknown = Object.keys(props).filter(
    (key) => !Object.keys(OPTIONS).includes(key),
  );
  if (unknown.length > 0) {
    throw new Error(
      `[Rokt] Unknown @rokt/react-native-sdk plugin option ${unknown.join(", ")}. Options: ${Object.keys(OPTIONS).join(", ")}.`,
    );
  }
  const manager = props.iosDependencyManager ?? "spm";
  if (manager === "spm") {
    // The podspec links the Rokt iOS SDK as a Swift package on `pod install`; no hook is needed.
    return setSettings(podfile, settingsLines(props));
  }
  if (manager !== "cocoapods") {
    throw new Error(
      `[Rokt] iosDependencyManager must be "spm" or "cocoapods", not ${JSON.stringify(manager)}`,
    );
  }
  return addDynamicFrameworkHook(
    setSettings(podfile, ["$RNRoktDisableSPM = true"]),
  );
}

const withRoktPodfile: ConfigPlugin<RoktPluginProps> = (config, props) => {
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

      const podfileContent = fs.readFileSync(podfilePath, "utf-8");
      fs.writeFileSync(
        podfilePath,
        applyRoktPodfileMods(podfileContent, props),
        "utf-8",
      );

      return config;
    },
  ]);
};

/**
 * Expo Config Plugin for Rokt React Native SDK
 *
 * Configures the iOS Podfile:
 * - Swift Package Manager (the default): writes the optional SDK version and packages, which
 *   `pod install` uses to link the Rokt iOS SDK into the app as a Swift package
 * - CocoaPods (deprecated): opts out of Swift Package Manager and injects the pre_install hook for
 *   dynamic framework linking of Rokt pods
 *
 * Android requires no modifications — autolinking and Maven Central handle
 * package registration and dependency resolution automatically.
 */
const withRoktSDK: ConfigPlugin<RoktPluginProps | void> = (config, props) => {
  config = withRoktPodfile(config, props ?? {});
  return config;
};

export default withRoktSDK;
