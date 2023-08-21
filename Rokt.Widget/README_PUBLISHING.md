
# @rokt/react-native-sdk
## Resident Experts

- Danial Motahari - danial.motahari@rokt.com
- Sahil Suri - sahil.suri@rokt.com

## Overview
The React Native SDK enables you to integrate Rokt into your React Native mobile apps to drive more value from—and for—your customers. The SDK is built to be lightweight, secure, and simple to integrate and maintain, resulting in minimal lift for your engineering team.
The SDK includes the common functionality in the ```*.js files``` whereas the platform specific code is written in the respective platform package example ```android or ios```.
We use ```npm``` package manager to manage the dependencies for the project.

| Environment | Build |
| ----------- | :----- |
| release |  [![Build status](https://badge.buildkite.com/e75677bd3c8e83f1da750aa9124df1f418f211c9c630765ffd.svg)](https://buildkite.com/rokt/react-native-sdk)

## CI/CD System

The CI system used is [**Buildkite**](https://buildkite.com/rokt/react-native-sdk). Buildkite workflows are defined in the `.buildkite` directory. There are two seperate workflows that are executed based on branch names. 
Branches with **release-** prefix are considered production branches, the publish step will release to the production [**NPM Respository**](https://www.npmjs.com/package/@rokt/react-native-sdk)
All other branches are considered alpha branches, so it will publish to maven with with **-alpha** postfix. 

## Publishing
This SDK is published to a NPM package repository. The publishing step uses the fastlane lanes ```publishAlphaSDK``` or ```publishSDK``` for publishing the alpha or production version respectively to NPM. The fastlane file is located inside ```RoktSampleApp/android```
The steps are configured in `publish.gradle`.
Publishing  Alpha and prod are possible through Buildkite based on the Git branch names as explained in above step.

## Local Setup
Go to the root of the project **Rokt.Widget** " and run ```npm install```.
This will install all required packages for the project.  

To lint run ```npm run lint```.

To test the local changes, execute the ```npm run build``` then ```npm pack ``` to create the SDK package name as ```rokt-react-native-sdk-X.X.X.tgz```. To change the version ```X.X.X``` , go to the ```package.json``` and modify the version field to new version. 
Then we need to go RoktSampleApp project ```package.json``` to point to ```rokt-react-native-sdk-X.X.X.tgz``` file.


## License 
Copyright 2020 Rokt Pte Ltd 

Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); 
You may not use this file except in compliance with the License. 
You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
