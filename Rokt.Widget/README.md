# @rokt/react-native-sdk

| Environment | Build |
| ----------- | :----- |
| release |  [![CircleCI](https://circleci.com/bb/ROKT/rokt-sdk-ios/tree/master.svg?style=svg&circle-token=519d542734b554bf3484517306ccecddd243e78c)]


## CI/CD System

The CI system used is **CircleCi**  https://app.circleci.com/pipelines/github/ROKT/rokt-sdk-react-native
CircleCi workflows are defined in the `.circleci` directory. There are two seperate workflows that are executed based on branch names. 
Branches with **release-** prefix are considered production branches, the publish step will release to the production maven respository.
All other branches are considered alpha branches, so it will publish to maven with with **-alpha** postfix. 

## Publishing
This SDK is published to a NPM package repository. The publishing step uses the fastlane lanes publishAlphaSDK or publishSDK for publishing the alpha or production version to NPM. The fastlane file is located inside ```RoktSampleApp/android```
The steps are configured in `publish.gradle`.
Publishing  Alpha and prod are possible through CircleCi based on the Git branch names as explained in above step.

## Local Changes
To Test the local changes, execute the ```$ npm pack ``` to create the SDK package. To change the version of the package, go to the ```package.json``` and modify the version field to new version.


## License 
Copyright 2020 Rokt Pte Ltd 

Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); 
You may not use this file except in compliance with the License. 
You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/