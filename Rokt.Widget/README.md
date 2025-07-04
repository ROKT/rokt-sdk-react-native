# @rokt/react-native-sdk

## Overview

This repository contains React Native SDK [Rokt.Widget](Rokt.Widget) as well as the Sample Application [RoktSampleApp](RoktSampleApp) .

The React Native SDK enables you to integrate Rokt into your React Native mobile apps to drive more value from—and for—your customers. The SDK is built to be lightweight, secure, and simple to integrate and maintain, resulting in minimal lift for your engineering team. The RoktSampleApp includes bare-minimum UI to demonstrate the usage of React Native SDK for our partners using the [Integration guide](#integration-guide-for-apps)

## Development Environment

Install ReactNative development environment by following the [React Native environment setup guide](https://reactnative.dev/docs/environment-setup).

For this project, a minimum `Ruby` version `2.7.6` is required. Check by running `ruby -v` on your terminal.

## Integration Guide for Apps

To add this SDK in your Application, Go to the root of your project in your terminal and add run the below commands:

`$ npm install @rokt/react-native-sdk --save`

run `$ npm install`

You would also need to

### Android Configuration

1.  Add the Rokt Widget plugin repository URL in the `build.gradle` file of the project.

```groovy
allprojects {
    repositories {
        ...
        maven {
            url  "https://apps.rokt.com/msdk"
        }
    }
}
```

Or if you are using [Gradle](https://gradle.org/) 7.0.0 and above, where the repository settings that were previously in the top-level build.gradle file are now in the settings.gradle file, add the following in settings.gradle file.

```groovy
dependencyResolutionManagement {
	repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
	repositories {
		google()
		mavenCentral()
		// Rokt SDK artifacts
		maven {
			url "https://apps.rokt.com/msdk"
		}
	}
}
```

#### File: MainApplication.java (Module: app)

2. In your ReactApplication class, make sure you add the RoktEmbeddedViewPackage to the getPackages method:

```java

// import the class
import com.rokt.reactnativesdk.RoktEmbeddedViewPackage;

@Override
protected List<ReactPackage> getPackages() {
	@SuppressWarnings("UnnecessaryLocalVariable")
    List<ReactPackage> packages = new PackageList(this).getPackages();
    //Add the RoktEmbeddedViewPackage
    packages.add(new RoktEmbeddedViewPackage());
    return packages;
}
```

##### File: .gradle (Module: app)

3. It's likely that you will need multiDexEnabled as well
4. Make sure you are targeting mindSdk version 18 or higher.

```groovy
android {
    ...
    defaultConfig {
        ...
        multiDexEnabled true,
        minSdkVersion 18
    }
}
```

...

### iOS Configuration

#### Install the pods

go to ios folder and run command below to install the [pod](https://cocoapods.org/)

```shell
pod install
```

Below Configurations are required only if you are using Mac M1 machines:

1. Make sure cocoa pods are installed using gem not brew(sudo gem install [cocoapods](https://cocoapods.org/).  
   If it is already installed using brew, use below commands to uninstall them

```shell
brew uninstall cocoapods
brew uninstall --ignore-dependencies ruby
```

2. Install cocoapods with gem

```shell
Sudo gem install cocoapods
```

4. Replace the post_install in ios/podfile with below code

```ruby
post_install do |installer|
  react_native_post_install(installer)

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Disable arm64 builds for the simulator
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
```

4. Reinstall the pods:

```shell
cd ios
pod deintegrate
sudo arch -x86_64 gem install ffi
arch -x86_64 pod install
```

### Expo

This package cannot be used with "Expo Go" app, because it requires custom native code.
Integration with Expo is possible in both bare workflow and custom managed workflow via config plugis.

### Bare Workflow

If using Bare Workflow, follow the above Android and iOS setup steps.

### Managed Workflow

Since Expo Go will not work with react-native-sdk, the suggested workflow is to use a custom development client. If starting a new app, you can run `npx create-react-native-app -t with-dev-client` to have this set up automatically. It will also allow you to use the Expo Application Service (EAS Build) do the Android and iOS builds.
After installing the @rokt/react-native-sdk NPM package, add the config plugin to the plugins array of your app.json or app.config.js.

```json
{
  "expo": {
    "plugins": ["@rokt/react-native-sdk"]
  }
}
```

If you are not using EAS Build then you must use the `expo prebuild --clean` command as described in the [Adding custom native code](https://docs.expo.dev/workflow/customizing/) guide to rebuild your app with the plugin changes.

### Usage

#### Initialising the SDK

- Rokt Module provides two methods:

1. initialize(string ROKT_TAG_ID, string AppVersion)
2. execute(string TemplateVersion, object UserAttributes, object placements, function onLoad)

- The Initialize Method will fetch API results that Execute Method would need. so best not to put both calls next to each other.

##### Import

```javascript
import { Rokt, RoktEmbeddedView } from "@rokt/react-native-sdk";
```

##### Initialize

```javascript
Rokt.initialize("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "1.0");
```

#### To launch Overlay placement

##### Execute Overlay

```javascript
attributes = {
  email: "j.smith@example.com",
  firstname: "Jenny",
  lastname: "Smith",
  mobile: "(323) 867-5309",
  postcode: "90210",
  country: "US",
};
Rokt.execute("RoktExperience", attributes, null, () =>
  console.log("Placement Loaded"),
);
```

#### To launch Embedded placement

##### Create placeholder

```javascript
  constructor(props){
    super(props);
    this.placeholder1 = React.createRef();
  }

```

in render()

```tsx
<RoktEmbeddedView
  ref={this.placeholder1}
  placeholderName={"RoktEmbedded1"}
></RoktEmbeddedView>
```

##### Execute Embedded

```javascript
placeholders = {
  RoktEmbedded1: findNodeHandle(this.placeholder1.current),
};

attributes = {
  email: "j.smith@example.com",
  firstname: "Jenny",
  lastname: "Smith",
  mobile: "(323) 867-5309",
  postcode: "90210",
  country: "US",
};
Rokt.execute("RoktEmbeddedExperience", attributes, placeholders, () =>
  console.log("Placement Loaded"),
);
```

## License

Copyright 2020 Rokt Pte Ltd

Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License");
You may not use this file except in compliance with the License.
You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
