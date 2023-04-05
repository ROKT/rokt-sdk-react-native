/** @format */

// import { Navigation } from "react-native-navigation";
// // import {AppRegistry} from 'react-native';
// import App from './App';
// // import {name as appName} from './app.json';

// // AppRegistry.registerComponent(appName, () => App);


// Navigation.registerComponent('com.myApp.WelcomeScreen', () => App);
// Navigation.events().registerAppLaunchedListener(() => {
//        Navigation.setRoot({
//  root: {
//  stack: {
//  children: [
//                    {
//  component: {
//  name: 'com.myApp.WelcomeScreen'
//                      }
//            }
//              ]
//            }
//          }
//       });
// });




//---------------------


// In index.js of a new project
import React, { Component } from 'react';
import { View, Text, Button, StyleSheet, TouchableOpacity } from 'react-native';
import { Navigation } from 'react-native-navigation';

import { Rokt } from "@rokt/react-native-sdk";

// Home screen declaration
const HomeScreen = (props) => {
    return (
        <View style={styles.root}>
            <Text>Hello React Native Navigation 👋</Text>
            <Button
                title='Push Screen1'
                color='#710ce3'
                onPress={() => {
                    Rokt.initialize("3097723249469190400", "1.0");
                    Navigation.push(props.componentId, {
                        component: {
                            name: 'Screen1',
                            options: {
                                topBar: {
                                    title: {
                                        text: 'Screen1'
                                    }
                                }
                            }
                        }
                    })
                }} />

        </View>
    );
};
HomeScreen.options = {
    topBar: {
        title: {
            text: 'Home',
            color: 'white'
        },
        background: {
            color: '#4d089a'
        }
    }
};


class RoktScreen extends Component {
    componentDidMount() {
        const attributes = {
            email: "john@mail.com",
            firstname: "MATT",
            lastname: "JOHNS",
            mobile: "1234567890",
            postcode: "12345",
            country: "US",
            confirmationref: "123456",
            amount: 150.00,
            currency: "USD",
            Language: "en-US"

        };

        Rokt.execute("RoktExperience", attributes, {}, () =>
            console.log("Placement Loaded")
        );
    }

    render() {
        return <Text>Hello, I am your Rokt!</Text>;
    }
}

const Screen1 = (props) => {
    return (
        <View style={styles.root}>
            <View style={{ margin: 20 }}>
                <TouchableOpacity onPress={() => {
                    Navigation.push(props.componentId, {
                        component: {
                            name: 'Screen2',
                            options: {
                                topBar: {
                                    title: {
                                        text: 'Screen2'
                                    }
                                }
                            }
                        }
                    })

                }}><Text>Push  Screen 2</Text></TouchableOpacity>
            </View>


        </View>
    );
}

const Screen2 = (props) => {
    return (
        <View style={styles.root}>
            <View style={{ margin: 20 }}>
                <TouchableOpacity onPress={() => {
                    Navigation.setStackRoot('HOME_TAB',
                        [
                            {
                                "component": {
                                    "id": "Home",
                                    "name": "Home",
                                    "title": "Home",
                                    "passProps": {},
                                    "animated": true,
                                    "waitForRender": true,
                                    "options": {
                                        "bottomTabs": {
                                            "visible": true
                                        },
                                        "animations": {
                                            "push": {
                                                "enabled": true,
                                                "waitForRender": true
                                            },
                                            "pop": {
                                                "enabled": true,
                                                "waitForRender": true
                                            },
                                            "setStackRoot": {
                                                "enabled": false
                                            }
                                        },
                                        "layout": {
                                            "backgroundColor": "#f4f4f4",
                                            "orientation": [
                                                "portrait"
                                            ]
                                        },
                                        "topBar": {
                                            "visible": false,
                                            "height": 1,
                                            "drawBehind": true,
                                            "background": {
                                                "color": "#212A33"
                                            },
                                            "rightButtons": {

                                                "text": "",
                                                "enabled": false,
                                                "color": "#368ABB"
                                            },
                                            "leftButtons": {

                                                "text": "",
                                                "enabled": false
                                            }
                                        },
                                        "sideMenu": {
                                            "right": {
                                                "shouldStretchDrawer": true,
                                                "animationVelocity": 2600
                                            }
                                        },
                                        "popGesture": false
                                    }
                                }
                            },
                            {
                                "component": {
                                    "id": "Rokt",
                                    "name": "Rokt",
                                    "title": "Rokt",
                                    "passProps": {},
                                    "animated": true,
                                    "waitForRender": true,
                                    "options": {
                                        "bottomTabs": {
                                            "visible": false
                                        },
                                        "animations": {
                                            "push": {
                                                "waitForRender": true
                                            },
                                            "pop": {
                                                "waitForRender": true
                                            },
                                            "setStackRoot": {
                                                "waitForRender": true
                                            },
                                            "setRoot": {
                                                "waitForRender": true
                                            }
                                        },
                                        "layout": {
                                            "backgroundColor": "#f4f4f4",
                                            "orientation": [
                                                "portrait"
                                            ]
                                        },
                                        "topBar": {
                                            "noBorder": true,
                                            "visible": true,
                                            "animate": false,
                                            "drawBehind": false,
                                            "elevation": 0,
                                            "title": {},
                                            "rightButtons": {
                                                "id": "MenuButton",
                                                "text": "",
                                                "enabled": false,
                                                "color": "#368ABB"
                                            },

                                            "background": {
                                                "color": "#FFFFFF"
                                            }
                                        },
                                        "sideMenu": {
                                            "right": {
                                                "shouldStretchDrawer": true,
                                                "animationVelocity": 2600
                                            }
                                        },
                                        "popGesture": false
                                    }
                                }
                            }
                        ]
                    )

                }}><Text>Set stack RoketScreen</Text></TouchableOpacity>
            </View>
        </View>
    );
}

Navigation.registerComponent('Home', () => HomeScreen);
Navigation.registerComponent('Rokt', () => RoktScreen);
Navigation.registerComponent('Screen1', () => Screen1);
Navigation.registerComponent('Screen2', () => Screen2);

Navigation.events().registerAppLaunchedListener(async () => {
    Navigation.setRoot({
        root: {
            bottomTabs: {
                id: 'BOTTOM_TABS_LAYOUT',
                children: [
                    {
                        stack: {
                            id: 'HOME_TAB',
                            children: [
                                {
                                    component: {
                                        id: 'Home',
                                        name: 'Home'
                                    }
                                }
                            ],
                            options: {
                                bottomTab: {
                                    text: "HOME"
                                }
                            }
                        }
                    },
                    {
                        stack: {
                            id: 'PROFILE_TAB',
                            children: [
                                {
                                    component: {
                                        id: 'Screen1',
                                        name: 'Screen1'
                                    }
                                }
                            ],
                            options: {
                                bottomTab: {
                                    text: "PROFILE"
                                }
                            }
                        }
                    }
                ]
            }
        }

    });
});

const styles = StyleSheet.create({
    root: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: 'whitesmoke'
    }
});