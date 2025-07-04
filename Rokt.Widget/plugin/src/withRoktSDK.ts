import {
  ConfigPlugin,
  withProjectBuildGradle,
  withMainApplication,
} from "@expo/config-plugins";
import { addImports } from "@expo/config-plugins/build/android/codeMod";

const IMPORT_STATEMENT = "com.rokt.reactnativesdk.RoktEmbeddedViewPackage";
const ADD_PACKAGE = "packages.add(new RoktEmbeddedViewPackage());";
const GRADLE_MAVEN =
  'allprojects { repositories { maven { url "https://apps.rokt.com/msdk" } } }';

function addRoktJavaPackage(javaSource: string, javaInsert: string): string {
  const lines = javaSource.split("\n");
  const getPackageIndex = lines.findIndex((line) =>
    line.match(/return packages;/),
  );
  lines.splice(getPackageIndex, 0, javaInsert);
  return lines.join("\n");
}

function addRoktKotlinPackage(kotlinSource: string): string {
  return kotlinSource.replace(
    "return PackageList(this).packages",
    "return PackageList(this).packages.apply { add(RoktEmbeddedViewPackage()) }",
  );
}

const withRoktMainApplication: ConfigPlugin = (configuration) => {
  return withMainApplication(configuration, (config) => {
    if (["java", "kt"].includes(config.modResults.language)) {
      const isJava = config.modResults.language === "java";
      try {
        config.modResults.contents = addImports(
          config.modResults.contents,
          [IMPORT_STATEMENT],
          isJava,
        );
        if (isJava) {
          config.modResults.contents = addRoktJavaPackage(
            config.modResults.contents,
            ADD_PACKAGE,
          );
        } else {
          config.modResults.contents = addRoktKotlinPackage(
            config.modResults.contents,
          );
        }
      } catch (e) {
        throw new Error("Cannot add RoktSDK to the project's MainApplication.");
      }
    }
    return config;
  });
};

const withRoktProjectBuildGradle: ConfigPlugin = (config) => {
  return withProjectBuildGradle(config, (config) => {
    let content = config.modResults.contents;
    if (
      !content.includes("rokt-eng-us") &&
      !content.includes("apps.rokt.com")
    ) {
      content = `${content} \n ${GRADLE_MAVEN}`;
    }
    config.modResults.contents = content;
    return config;
  });
};

const withRoktSDK: ConfigPlugin = (config) => {
  withRoktMainApplication(config);
  withRoktProjectBuildGradle(config);
  return config;
};

export default withRoktSDK;
