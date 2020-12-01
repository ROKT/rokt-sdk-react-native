/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View,findNodeHandle, TouchableOpacity, SafeAreaView, ScrollView} from 'react-native';
import {Rokt, RoktEmbeddedView} from 'react-native-rokt-widget';

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

const embeddedAndLightbox = "testiOS";
const embeddedAndroid = "testAndroidLboxAndE";
const roktViewName = "testTwoEmbedded"

export default class App extends Component {
  constructor(props){
    super(props);
    this.placeholder1 = React.createRef();
    this.placeholder2 = React.createRef();
  }

  onInitHandler = () => {
    console.log(Rokt)
    Rokt.initialize("2754655826098840951", "1.1");
    console.log("Initialize");
  }

  onExecuteHandler = () => {
    attributes = {
      "email": "j.smith@example.com",
      "firstname": "Jenny",
      "lastname": "Smith",
      "mobile": "(323) 867-5309",
      "postcode": "90210",
      "country": "AU"
    }
        
    placeholders = {
      "Location1": findNodeHandle(this.placeholder1.current),
      "Location2": findNodeHandle(this.placeholder2.current),
    }

    Rokt.execute(roktViewName, attributes, placeholders,
    x => {
      console.log("Placement OnLoad Callback");
    });
    console.log("Execute");
  }

  render() {
    return (              
      
	<SafeAreaView style={styles.containerScroll}>
		<ScrollView style={styles.scrollView}>
			<View style={styles.container}>
				<Text style={styles.welcome}>Welcome to React Native</Text>
				<Text style={styles.roktMessage}>Rokt Widget Integration!</Text>
				<Text style={styles.instructions}>{instructions}</Text>
				<TouchableOpacity onPress={this.onInitHandler}>
					<Text style={styles.button}>Initialize</Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={this.onExecuteHandler}>
					<Text style={styles.button}>Execute</Text>
				</TouchableOpacity>
			</View>
      {/* <RoktWidget ref={this.widgetRef1} palcementName={"Location1"} ></RoktWidget> */}
			<RoktEmbeddedView ref={this.placeholder1} placeholderName={"Location1"} ></RoktEmbeddedView>
			<RoktEmbeddedView ref={this.placeholder2} placeholderName={"Location2"} ></RoktEmbeddedView>
			<View style={styles.afterWidget}/>
		</ScrollView>
	</SafeAreaView>);
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  roktMessage: {
    fontSize: 20,
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  button: {
    backgroundColor: '#4ba9c8',
    borderColor: 'white',
    borderWidth: 1,
    borderRadius: 12,
    color: 'white',
    fontSize: 24,
    fontWeight: 'bold',
    overflow: 'hidden',
    padding: 12,
    textAlign:'center',
  },
  afterWidget: {
    height: 10,
    backgroundColor: '#121212'
  }
});
