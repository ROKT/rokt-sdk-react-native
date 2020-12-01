
# react-native-rokt-widget

## Getting started

`$ npm install react-native-rokt-widget --save`

### Mostly automatic installation

run `$ react-native link react-native-rokt-widget`

run `$ npm install`


## Android Configuration

### Gradle Configurations (Added to your Project's gradle files):
#### File: .gradle (Project: YourProjectName)

1. Add Maven Repository of Rokt SDK
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

#### File: MainApplication.java (Module: app)
2. In your ReactApplication class, make sure you add the RoktWidgetViewPackage to the getPackages method:
```
        @Override
        protected List<ReactPackage> getPackages() {
          @SuppressWarnings("UnnecessaryLocalVariable")
          List<ReactPackage> packages = new PackageList(this).getPackages();

          //Add the RoktWidgetViewPackage
          packages.add(new RoktWidgetViewPackage());
          return packages;
        }
 ```

#### File: .gradle (Module: app)
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
## iOS Configuration

### Install the pods
go to ios folder and run command below to install the pod
```
pod install
```


## Usage

### Initialising the SDK

- Rokt Module provides two methods:
1. initialize(string ROKT_TAG_ID, string AppVersion)
2. execute(string TemplateVersion, object UserAttributes, object placements, function onLoad)
- The Initialize Method will fetch API results that Execute Method would need. so best not to put both calls next to each other.

#### Import 
```
import {Rokt, RoktEmbeddedView} from 'react-native-rokt-widget';;
```

#### Initialize
```
Rokt.initialize( "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" , "1.0");
```

### To launch Overlay placement

#### Execute 
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


### To launch Embedded placement

#### Create placeholder
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



#### Execute
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
Rokt.execute("RoktEmbeddedExperience", attributes, placeholders,  () => console.log("Widget Loaded"));
```


## License 
Copyright 2020 Rokt Pte Ltd 

Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); 
You may not use this file except in compliance with the License. 
You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
