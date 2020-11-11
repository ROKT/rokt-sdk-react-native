/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View, Button,findNodeHandle, TouchableOpacity} from 'react-native';
import Rokt from './native-modules/rokt-module'
import RoktWidget from './widget'
const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

type Props = {};
const embeddedAndLightbox = "testiOS";
const embedded = "testAndroidLightbox";

export default class App extends Component<Props> {

  constructor(props){
    super(props);
    // this.view1 = React.createRef();
    this.myRef = React.createRef();
  }

  onInitHandler = () => {
    console.log(Rokt)
    Rokt.initialize("2754655826098840951", "1.1");
    console.log("Initialize");
  }

  onExecuteHandler = () => {
    jenny = {
      "email": "j.smith@example.com",
      "firstname": "Jenny",
      "lastname": "Smith",
      "mobile": "(323) 867-5309",
      "postcode": "90210",
      "country": "AU"
    }

    console.log("Thisview1 = " + JSON.stringify(this.view1));
    
    //this.view1.getNativeParent()
    
    placeholders = {
      "Location1": findNodeHandle(this.myRef.current)
    }

    Rokt.execute(embeddedAndLightbox, jenny, placeholders,
    x => {
      console.log("Widget OnLoad Callback");
    });
    console.log("Execute");
  }

  render() {
    return (
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

        <RoktWidget ref={this.myRef} style={styles.widget}></RoktWidget>
      </View>
    );
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
  widget: {
    width: 300,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#94F1FF',
  },
});
