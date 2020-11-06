
# react-native-rokt-widget

## Getting started

`$ npm install react-native-rokt-widget --save`

### Mostly automatic installation

`$ react-native link react-native-rokt-widget`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-rokt-widget` and add `RNRoktWidget.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNRoktWidget.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNRoktWidgetPackage;` to the imports at the top of the file
  - Add `new RNRoktWidgetPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-rokt-widget'
  	project(':react-native-rokt-widget').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-rokt-widget/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-rokt-widget')
  	```


## Android Configuration

### AndroidX (AndroidX is required to use Rokt Library)
Please refer to [Migrate React Android Library to AndroidX](https://rokton.atlassian.net/wiki/spaces/RHC/pages/503580544/) document to migrate to AndroidX before doing any of the following

### Gradle Configurations (Added to your Project's gradle files):
#### File: .gradle (Project: YourProjectName)
Add Maven Repository of Rokt SDK
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

#### File: .gradle (Module: app)
1. Add DataBinding to Gradle
2. Very likely that you will need multiDexEnabled as well
3. In the dependencies section add RoktSdk reference and also Google Play Ads Service

```
android {
     
    ...
    defaultConfig {
        ...
        multiDexEnabled true
    }
    ...
    dataBinding {
        enabled = true
    }
}
...
dependencies {
    ...
     
    implementation 'com.rokt:roktsdk:1.16'
    implementation 'com.google.android.gms:play-services-ads:X.X.X'
    ...
}
```


#### File: gradle.properties
1. add : android.databinding.enableV2=true
```
...
android.databinding.enableV2=true
 
...
```
## iOS Configuration
### Install [Cocoapods](https://cocoapods.org/)

### Add these lines into your Podfile
```
use_frameworks!
pod 'Rokt-Widget'
```
### Install the pods
```
pod install
```

## Usage

- Rokt Module provides two methods:
1. initialize(string ROKT_TAG_ID, string AppVersion)
2. execute(string TemplateVersion, object UserAttributes, function onLoad)
- The Initialize Method will fetch API results that Execute Method would need. so best not to put both calls next to each other.

### Import 
```
import RNRoktWidget from 'react-native-rokt-widget';
```

### Initialize
```
RNRoktWidget.initialize( "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" , "1.0");
```

### Execute
```
jenny = {
      "email": "j.smith@example.com",
      "firstname": "Jenny",
      "lastname": "Smith",
      "mobile": "(323) 867-5309",
      "postcode": "90210",
      "country": "US"
}
RNRoktWidget.execute("RoktExperience", jenny, () => console.log("Widget Loaded"));
```

## License 
Copyright 2018 Rokt Pte Ltd

Licensed under the Rokt Software Development Kit (SDK) Terms of Use
Version 1.0 (the "License");
You may not use this file except in compliance with the License.
You may obtain a copy of the License at https://appsapi.rokt.com/Documents/Rokt/SDKLicense
