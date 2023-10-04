import { ConfigPlugin, withProjectBuildGradle, withMainApplication } from '@expo/config-plugins';

const IMPORT_STATEMENT = 'com.reactlibrary.RoktEmbeddedViewPackage';
const ADD_PACKAGE = 'packages.add(new RoktEmbeddedViewPackage());'
const GRADLE_MAVEN =
  'allprojects { repositories { maven { url "https://rokt-eng-us-west-2-mobile-sdk-artefacts.s3.amazonaws.com" } } }';


function addJavaImports(javaSource: string, javaImports: string[]): string {
    const lines = javaSource.split('\n');
    const lineIndexWithPackageDeclaration = lines.findIndex((line) => line.match(/^package .*;$/));
    for (const javaImport of javaImports) {
      if (!javaSource.includes(javaImport)) {
        const importStatement = `import ${javaImport};`;
        lines.splice(lineIndexWithPackageDeclaration + 1, 0, importStatement);
      }
    }
    return lines.join('\n');
}

function addGetPackage(javaSource: string, javaInsert: string): string {
    const lines = javaSource.split('\n');
    const getPackageIndex = lines.findIndex((line) => line.match(/return packages;/));
    lines.splice(getPackageIndex, 0, javaInsert);
    return lines.join('\n');
}

const withRoktMainApplication: ConfigPlugin = (config) => {
    return withMainApplication(config, (config) => {
        if (config.modResults.language === 'java') {
            let content = config.modResults.contents;
            content = addJavaImports(content, [IMPORT_STATEMENT]);
            content = addGetPackage(content, ADD_PACKAGE);
            config.modResults.contents = content;
        }
        return config
    });
};

const withRoktProjectBuildGradle: ConfigPlugin = (config) => {
    return withProjectBuildGradle(config, (config) => {
        let content = config.modResults.contents;
        if (!content.includes('rokt-eng-us')) {
            content = `${content} \n ${GRADLE_MAVEN}`
        }
        config.modResults.contents = content;
        return config
    });
};

const withRoktSDK: ConfigPlugin = (config) => {
    withRoktMainApplication(config);
    withRoktProjectBuildGradle(config)
    return config;
};


export default withRoktSDK;