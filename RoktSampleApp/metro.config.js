/**
 * Metro configuration for React Native
 * https://github.com/facebook/react-native
 *
 * @format
 */

const packagePath =
    '../Rokt.Widget';

module.exports = {
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true,
      },
    }),
  },
resolver: {
        nodeModulesPaths: [packagePath],
        // rest of metro resolver options...
    },
watchFolders: [packagePath],
};
