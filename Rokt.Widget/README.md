
# react-native-rokt-widget

## Getting started

`$ npm install react-native-rokt-widget --save`

### Mostly automatic installation

run `$ react-native link react-native-rokt-widget`

run `$ npm install`


## Android Configuration

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
3. It's likely that you will need multiDexEnabled as well, if so, you can enable it like this:
```
android {
    ...
    defaultConfig {
        ...
        multiDexEnabled true
    }
}
```

...
```
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
import {Rokt, RoktWidget} from 'react-native-rokt-widget';;
```

#### Initialize
```
Rokt.initialize( "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" , "1.0");
```

### To launch Overlay placement

#### Execute 
```
jenny = {
      "email": "j.smith@example.com",
      "firstname": "Jenny",
      "lastname": "Smith",
      "mobile": "(323) 867-5309",
      "postcode": "90210",
      "country": "US"
}
Rokt.execute("RoktExperience", jenny, null,  () => console.log("Widget Loaded"));
```


### To launch Embedded placement

#### Create placements
```
  constructor(props){
    super(props);
    this.widgetRef1 = React.createRef();
  }

```

in render() 
```
<RoktWidget ref={this.widgetRef1} palcementName={"RoktEmbedded1"} ></RoktWidget>

```



#### Execute
```
placements = {
      "RoktEmbedded1": findNodeHandle(this.widgetRef1.current)
}

jenny = {
      "email": "j.smith@example.com",
      "firstname": "Jenny",
      "lastname": "Smith",
      "mobile": "(323) 867-5309",
      "postcode": "90210",
      "country": "US"
}
Rokt.execute("RoktEmbeddedExperience", jenny, placements,  () => console.log("Widget Loaded"));
```


## License 
Copyright 2020 Rokt Pte Ltd 

Licensed under the Rokt Software Development Kit (SDK) Terms of Use Version 2.0 (the "License"); 
You may not use this file except in compliance with the License. 
You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
