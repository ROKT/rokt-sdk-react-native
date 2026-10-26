import { applyRoktPodfileMods } from "../plugin/src/withRoktSDK";

// The shape of the Podfile that `expo prebuild` generates, trimmed to the lines the plugin touches.
const PODFILE = `require File.join(File.dirname(\`node --print "require.resolve('expo/package.json')"\`), "scripts/autolinking")

platform :ios, podfile_properties['ios.deploymentTarget'] || '15.1'
install! 'cocoapods', :deterministic_uuids => false

target 'ExpoTestApp' do
  use_expo_modules!
end
`;

// What the plugin wrote before it had any options: the dynamic-framework hook after `platform`.
const LEGACY_HOOK = `
# Rokt SDK dynamic framework linking (added by @rokt/react-native-sdk expo plugin)
pre_install do |installer|
  installer.pod_targets.each do |pod|
    if pod.name == 'Rokt-Widget' || pod.name == 'RoktContracts' || pod.name == 'RoktUXHelper' || pod.name == 'DcuiSchema'
      def pod.build_type;
        Pod::BuildType.new(:linkage => :dynamic, :packaging => :framework)
      end
    end
  end
end
`;

function settings(...lines: string[]): string {
  return [
    "# Rokt settings (added by @rokt/react-native-sdk expo plugin)",
    ...lines,
    "# end of Rokt settings",
  ].join("\n");
}

describe("applyRoktPodfileMods", () => {
  test("defaults to Swift Package Manager: settings before the target, no hook", () => {
    const podfile = applyRoktPodfileMods(PODFILE);
    expect(podfile).toContain(`${settings()}\n\ntarget 'ExpoTestApp' do`);
    expect(podfile).not.toContain("pre_install");
    expect(podfile).not.toContain("RNRoktDisableSPM");
  });

  test("passes the SDK version and packages through", () => {
    const podfile = applyRoktPodfileMods(PODFILE, {
      iosSdkVersion: "5.5.5",
      iosSpmPackages: ["RoktPaymentExtension"],
    });
    expect(podfile).toContain(
      settings(
        "$RNRoktSPMVersion = '5.5.5'",
        "$RNRoktSPMPackages = ['RoktPaymentExtension']",
      ),
    );
  });

  describe.each(["spm", "cocoapods"] as const)(
    "%s with custom targets",
    (iosDependencyManager) => {
      test.each([
        ["space-indented", "  target 'ExpoTestApp' do\n  end\n"],
        ["tab-indented", "\ttarget 'ExpoTestApp' do\n\tend\n"],
        [
          "abstract",
          "abstract_target 'Common' do\n  use_expo_modules!\n  target 'ExpoTestApp' do\n  end\nend\n",
        ],
      ])(
        "writes settings before %s targets and preserves reruns",
        (_, targets) => {
          const props = {
            iosDependencyManager,
            ...(iosDependencyManager === "spm"
              ? {
                  iosSdkVersion: "5.5.5",
                  iosSpmPackages: ["RoktPaymentExtension"],
                }
              : {}),
          };
          const podfile = `platform :ios, '15.1'\n\n${targets}`;
          const modified = applyRoktPodfileMods(podfile, props);
          const block =
            iosDependencyManager === "spm"
              ? settings(
                  "$RNRoktSPMVersion = '5.5.5'",
                  "$RNRoktSPMPackages = ['RoktPaymentExtension']",
                )
              : settings("$RNRoktDisableSPM = true");

          expect(modified).toContain(`${block}\n\n${targets}`);
          expect(modified.match(/# Rokt settings/g)).toHaveLength(1);
          expect(applyRoktPodfileMods(modified, props)).toBe(modified);
        },
      );
    },
  );

  test("running again gives the same Podfile, and a rerun replaces the settings", () => {
    const once = applyRoktPodfileMods(PODFILE, { iosSdkVersion: "5.5.5" });
    expect(applyRoktPodfileMods(once, { iosSdkVersion: "5.5.5" })).toBe(once);

    const changed = applyRoktPodfileMods(once, { iosSdkVersion: "5.6.0" });
    expect(changed).toContain("$RNRoktSPMVersion = '5.6.0'");
    expect(changed).not.toContain("5.5.5");
    expect(changed.match(/# Rokt settings/g)).toHaveLength(1);
  });

  test("cocoapods keeps the earlier output and adds the opt-out", () => {
    const podfile = applyRoktPodfileMods(PODFILE, {
      iosDependencyManager: "cocoapods",
    });
    const earlier = PODFILE.replace(
      /platform :ios.*\n/,
      (line) => `${line}${LEGACY_HOOK}`,
    );
    expect(podfile).toBe(
      earlier.replace(
        "target 'ExpoTestApp' do",
        `${settings("$RNRoktDisableSPM = true")}\n\ntarget 'ExpoTestApp' do`,
      ),
    );
    expect(
      applyRoktPodfileMods(podfile, { iosDependencyManager: "cocoapods" }),
    ).toBe(podfile);
  });

  test("switching from cocoapods to spm drops the opt-out", () => {
    const cocoapods = applyRoktPodfileMods(PODFILE, {
      iosDependencyManager: "cocoapods",
    });
    expect(applyRoktPodfileMods(cocoapods)).not.toContain("RNRoktDisableSPM");
  });

  test("rejects values that could break out of the Ruby string", () => {
    expect(() =>
      applyRoktPodfileMods(PODFILE, { iosSdkVersion: "5.5.5'; system('x')" }),
    ).toThrow("iosSdkVersion");
    expect(() =>
      applyRoktPodfileMods(PODFILE, { iosSpmPackages: ["Rokt'Payment"] }),
    ).toThrow("iosSpmPackages");
  });

  test("rejects an unknown option, such as a misspelt one", () => {
    expect(() =>
      applyRoktPodfileMods(PODFILE, {
        iosSdkversion: "5.5.5",
      } as never),
    ).toThrow("iosSdkversion");
  });

  test("rejects iosSpmPackages that is not an array", () => {
    expect(() =>
      applyRoktPodfileMods(PODFILE, {
        iosSpmPackages: "RoktPaymentExtension" as never,
      }),
    ).toThrow("must be an array");
  });

  test("stops when the settings block has lost its end marker", () => {
    const broken = applyRoktPodfileMods(PODFILE).replace(
      "# end of Rokt settings",
      "",
    );
    expect(() => applyRoktPodfileMods(broken)).toThrow("prebuild --clean");
  });

  test("rejects an unknown dependency manager", () => {
    expect(() =>
      applyRoktPodfileMods(PODFILE, {
        iosDependencyManager: "carthage" as never,
      }),
    ).toThrow('"spm" or "cocoapods"');
  });

  test("stops when the Podfile has no target block", () => {
    expect(() => applyRoktPodfileMods("platform :ios, '15.1'\n")).toThrow(
      "no target block",
    );
  });
});
