# @rokt/react-native-sdk

## Resident Experts

- Danial Motahari - danial.motahari@rokt.com
- Sahil Suri - sahil.suri@rokt.com

## Overview

This repository contains React Native SDK [Rokt.Widget](Rokt.Widget) as well as the Sample Application [RoktSampleApp](RoktSample) .

The React Native SDK enables you to integrate Rokt into your React Native mobile apps to drive more value from—and for—your customers. The SDK is built to be lightweight, secure, and simple to integrate and maintain, resulting in minimal lift for your engineering team. The RoktSampleApp includes bare-minimum UI to demonstrate the usage of React Native SDK for our partners using the [Integration guide](##-integration-guide-for-demo-apps)

## Development Environment
Install ReactNative development environment by following the description [here](https://reactnative.dev/docs/environment-setup).

## Integration Guide for Demo Apps

To add this SDK in your Application, Go to the root of your project in your terminal and add run the below commands:

`$ npm install @rokt/react-native-sdk --save`

run `$ npm install`

You would also need to 
### Android Configuration


1.  Add the Rokt Widget plugin repository URL in the  ```build.gradle```  file of the project.
```
allprojects {
    repositories {
        ...
        maven {
            url  "https://rokt-eng-us-west-2-mobile-sdk-artefacts.s3.amazonaws.com"
        }
    }
}
```
Or if you are using [Gradle](https://gradle.org/) 7.0.0 and above, where the repository settings that were previously in the top-level build.gradle file are now in the settings.gradle file, add the following in settings.gradle file.
```
dependencyResolutionManagement {  
	repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)  
	repositories {  
		google()  
		mavenCentral()  
		jcenter()  // Warning: this repository is going to shut down soon  
		// Rokt SDK artifacts  
		maven {  
			url "https://rokt-eng-us-west-2-mobile-sdk-artefacts.s3.amazonaws.com"  
		}  
	}  
}
```
##### File: MainApplication.java (Module: app)
2. In your ReactApplication class, make sure you add the RoktEmbeddedViewPackage to the getPackages method:
```
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

```
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
```
pod install
```
Below Configurations are required only if you are using Mac M1 machines:

1. Make sure cocoa pods are installed using gem not brew(sudo gem install [cocoapods](https://cocoapods.org/).  
If it is already installed using brew, use below commands to uninstall them  
```
brew uninstall cocoapods  
brew uninstall --ignore-dependencies ruby
```

2. Install cocoapods with gem 
```
Sudo gem install cocoapods
```

4. Replace the post_install in ios/podfile with below code  
```
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

```
cd ios
pod deintegrate
sudo arch -x86_64 gem install ffi
arch -x86_64 pod install
```


### Usage

#### Initialising the SDK

- Rokt Module provides two methods:
1. initialize(string ROKT_TAG_ID, string AppVersion)
2. execute(string TemplateVersion, object UserAttributes, object placements, function onLoad)
- The Initialize Method will fetch API results that Execute Method would need. so best not to put both calls next to each other.

##### Import 
```
import { Rokt, RoktEmbeddedView } from "@rokt/react-native-sdk";
```

##### Initialize
```
Rokt.initialize( "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" , "1.0");
```

#### To launch Overlay placement

##### Execute 
```
attributes = {
      "email": "j.smith@example.com",
      "firstname": "Jenny",
      "lastname": "Smith",
      "mobile": "(323) 867-5309",
      "postcode": "90210",
      "country": "US"
}
Rokt.execute("RoktExperience", attributes, null,  () => console.log("Placement Loaded"));
```


#### To launch Embedded placement

##### Create placeholder
```
  constructor(props){
    super(props);
    this.placeholder1 = React.createRef();
  }

```

in render() 
```
<RoktEmbeddedView ref={this.placeholder1} placeholderName={"RoktEmbedded1"} ></RoktEmbeddedView>

```



##### Execute
```
placeholders = {
      "RoktEmbedded1": findNodeHandle(this.placeholder1.current)
}

attributes = {
      "email": "j.smith@example.com",
      "firstname": "Jenny",
      "lastname": "Smith",
      "mobile": "(323) 867-5309",
      "postcode": "90210",
      "country": "US"
}
Rokt.execute("RoktEmbeddedExperience", attributes, placeholders,  () => console.log("Placement Loaded"));
```


## License 
Copyright 2020 Rokt Pte Ltd 

Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); 
You may not use this file except in compliance with the License. 
You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
