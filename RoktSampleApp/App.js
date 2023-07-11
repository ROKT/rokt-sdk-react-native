/* eslint-disable react-native/no-inline-styles */
/**
 * Demo application to showcase Rokt React Native SDK usage.
 *
 * Copyright 2020 Rokt Pte Ltd
 *
 * Licensed under the Rokt Software Development Kit (SDK) Terms of Use
 * Version 2.0 (the "License");
 *
 * You may not use this file except in compliance with the License.
 *
 * You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
 */

import React, {Component} from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  TextInput,
  findNodeHandle,
  StatusBar,
  TouchableOpacity,
  NativeEventEmitter,
  Dimensions,
} from 'react-native';
import CheckBox from '@react-native-community/checkbox';
import Toast from 'react-native-toast-message';
import {isEmpty, isNotEmpty, isValidJson} from './utils/text-utils';
import {
  DEFAULT_ATTRIBUTES,
  DEFAULT_TAG_ID,
  DEFAULT_VIEW_NAME,
  DEFAULT_COUNTRY,
  FULLFILLMENT_ATTRIBUTES,
  PUBLIC_KEY_PROD,
  ENCRYPTION_KEY_ID_PROD,
  PUBLIC_KEY_STAGE,
  ENCRYPTION_KEY_ID_STAGE,
} from './utils/rokt-constants';
import {Colors} from 'react-native/Libraries/NewAppScreen';
import {Rokt, RoktEmbeddedView, RoktEventManager} from '@rokt/react-native-sdk';
import sha256 from 'crypto-js/sha256';
import {Buffer} from 'buffer';
import {WebView} from 'react-native-webview';
var forge = require('node-forge');

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

const deviceHeight = Dimensions.get('window').height;
const deviceWidth = Dimensions.get('window').width;

export default class App extends Component {
  constructor(props) {
    super(props);

    var attributes = JSON.stringify(DEFAULT_ATTRIBUTES);

    this.placeholder1 = React.createRef();
    this.placeholder2 = React.createRef();
    this.state = {
      tagId: DEFAULT_TAG_ID,
      viewName: DEFAULT_VIEW_NAME,
      country: DEFAULT_COUNTRY,
      targetElement1: 'Location1',
      targetElement2: 'Location2',
      attributes: attributes,
      stageEnabled: false,
      twoStepEnabled: false,
      encryptEnabled: false,
      showWebView: false,
      webViewUrl: 'https://example.com',
      webViewId: -1,
      withUrlListener: false,
    };
  }

  subscription = eventManagerEmitter.addListener(
    'FirstPositiveResponse',
    (x) => {
      console.log('Widget OnFirstPositiveEvent Callback');
      // Send unhashed email on first positive response
      Rokt.setFulfillmentAttributes(FULLFILLMENT_ATTRIBUTES);
    },
  );

  encrypt(text, publicKey) {
    var publicBytes = forge.util.decode64(publicKey);
    var pkeyAsn1 = forge.asn1.fromDer(publicBytes);
    var publicKey = forge.pki.publicKeyFromAsn1(pkeyAsn1);
    let toEncrypt = Buffer.from(text);
    let encrypted = publicKey.encrypt(toEncrypt, 'RSA-OAEP', {
      md: forge.md.sha256.create(),
    });
    return forge.util.encode64(encrypted);
  }

  componentWillUnmount() {
    this.subscription.remove();
  }

  onInitHandler = () => {
    if (isNotEmpty(this.state.tagId)) {
      if (this.state.stageEnabled) {
        console.log('Executing on Stage');
        Rokt.setEnvironmentToStage();
      } else {
        console.log('Executing on Prod');
        Rokt.setEnvironmentToProd();
      }
      Rokt.initialize(this.state.tagId, '1.1');
      console.log('Initialize');
    } else {
      this.showToast('Tag ID must be a valid string');
    }
  };

  showToast = (message) => {
    Toast.show({
      text1: 'Invalid form',
      text2: message,
      type: 'error',
      position: 'bottom',
      autoHide: true,
    });
  };

  execute2Step = async (attributes, placeholders) => {
    try {
      // first we send hashed email
      attributes.emailsha256 = sha256(attributes.email).toString();
      attributes.email = null;
      Rokt.execute2Step(
        this.state.viewName,
        attributes,
        placeholders,
        (onLoad) => {
          console.log('Widget OnLoad Callback');
        },
      );

      console.log('Execute 2 Step');
    } catch (e) {
      console.error(e);
    }
  };

  executeEncrypted = async (attributes, placeholders) => {
    try {
      let publicKey;

      if (this.state.stageEnabled) {
        publicKey = PUBLIC_KEY_STAGE;
        attributes.piiencryptionkeyid = ENCRYPTION_KEY_ID_STAGE;
      } else {
        publicKey = PUBLIC_KEY_PROD;
        attributes.piiencryptionkeyid = ENCRYPTION_KEY_ID_PROD;
      }

      // first we send hashed email
      attributes.emailEnc = this.encrypt(
        attributes.email,
        publicKey,
      ).toString();
      attributes.firstnameEnc = this.encrypt(
        attributes.firstname,
        publicKey,
      ).toString();
      attributes.email = null;
      attributes.firstname = null;

      Rokt.execute(this.state.viewName, attributes, placeholders, (onLoad) => {
        console.log('Widget OnLoad Callback');
      });

      console.log('Execute Encrypted');
    } catch (e) {
      console.error(e);
    }
  };

  onExecuteHandler = () => {
    var stateCopy = JSON.parse(JSON.stringify(this.state));

    if (!isValidJson(stateCopy.attributes)) {
      this.showToast('Attributes must be valid JSON');
      return;
    }

    var attributes = JSON.parse(stateCopy.attributes);

    attributes.country = this.state.country;

    // invalid attributes should be ignored by SDK
    attributes.testNullValue = null;
    attributes.testNotStringValue = 13;

    var placeholders = {};
    placeholders[this.state.targetElement1] = findNodeHandle(
      this.placeholder1.current,
    );
    placeholders[this.state.targetElement2] = findNodeHandle(
      this.placeholder2.current,
    );

    if (isEmpty(this.state.viewName)) {
      this.showToast('View Name cannot be empty');
    }

    if (this.state.withUrlListener) {
      eventManagerEmitter.addListener('OpenURL', (data) => {
        console.log('OpenURL ID: ' + data.urlId + ' URL: ' + data.urlString);
        this.setState({
          webViewUrl: data.urlString,
          webViewId: data.urlId,
        });
      });
    }

    if (this.state.twoStepEnabled) {
      this.execute2Step(attributes, placeholders);
    } else if (this.state.encryptEnabled) {
      this.executeEncrypted(attributes, placeholders);
    } else {
      Rokt.execute(this.state.viewName, attributes, placeholders, (x) => {
        console.log('Widget OnLoad Callback');
      });
      console.log('Execute');
    }
  };

  render() {
    return (
      <>
        <StatusBar barStyle="dark-content" />
        <SafeAreaView>
          <ScrollView
            contentInsetAdjustmentBehavior="automatic"
            style={styles.scrollView}>
            <View style={styles.body}>
              <View style={styles.sectionContainer}>
                <Text
                  style={[styles.sectionTitle, {marginBottom: 20}]}
                  testID="Welcome">
                  Welcome to Rokt Demo{' '}
                </Text>
                <Text style={[styles.label, {color: Colors.black}]}>
                  Rokt Tag ID:
                </Text>
                <TextInput
                  accessibilityLabel="input_tag_id"
                  testID="input_tag_id"
                  style={styles.textInput}
                  value={this.state.tagId}
                  onChangeText={(tagId) => this.setState({tagId})}
                />

                <View style={styles.horizontalContainer}>
                  <View style={[{height: 50, flex: 1, marginRight: 5}]}>
                    <Text style={[styles.label, {color: Colors.black}]}>
                      View Name:
                    </Text>
                    <TextInput
                      accessibilityLabel="input_view_name"
                      testID="input_view_name"
                      style={styles.textInput}
                      value={this.state.viewName}
                      onChangeText={(viewName) => this.setState({viewName})}
                    />
                  </View>
                  <View>
                    <Text style={[styles.label, {color: Colors.black}]}>
                      Country
                    </Text>
                    <TextInput
                      accessibilityLabel="input_view_country"
                      style={styles.textInput}
                      testID="input_view_country"
                      value={this.state.country}
                      onChangeText={(country) => this.setState({country})}
                    />
                  </View>
                </View>

                <Text style={[styles.label, {color: Colors.black}]}>
                  Target Element
                </Text>
                <TextInput
                  accessibilityLabel="input_target_element"
                  testID="input_target_element"
                  style={styles.textInput}
                  value={this.state.targetElement1}
                  onChangeText={(targetElement1) =>
                    this.setState({targetElement1})
                  }
                />
                <Text style={[styles.label, {color: Colors.black}]}>
                  Target Element
                </Text>
                <TextInput
                  style={styles.textInput}
                  value={this.state.targetElement2}
                  onChangeText={(targetElement2) =>
                    this.setState({targetElement2})
                  }
                />
                <Text style={[styles.label, {color: Colors.black}]}>
                  Attributes
                </Text>
                <TextInput
                  accessibilityLabel="input_attributes"
                  testID="input_attributes"
                  multiline
                  numberOfLines={4}
                  style={styles.multiLineText}
                  value={this.state.attributes}
                  onChangeText={(attributes) => {
                    console.log(attributes);
                    this.setState({attributes: attributes});
                  }}
                />

                <View style={{flexDirection: 'row'}}>
                  <CheckBox
                    accessibilityLabel="input_stage_env"
                    value={this.state.stageEnabled}
                    onValueChange={() =>
                      this.setState({stageEnabled: !this.state.stageEnabled})
                    }
                  />
                  <Text style={{marginTop: 5, marginLeft: 5}}>
                    Stage Environment
                  </Text>
                </View>
                <View style={{flexDirection: 'row'}}>
                  <CheckBox
                    accessibilityLabel="input_2step"
                    value={this.state.twoStepEnabled}
                    onValueChange={() =>
                      this.setState({
                        twoStepEnabled: !this.state.twoStepEnabled,
                      })
                    }
                  />
                  <Text style={{marginTop: 5, marginLeft: 5}}>
                    2Step Data Pass
                  </Text>
                </View>

                <View style={{flexDirection: 'row'}}>
                  <CheckBox
                    accessibilityLabel="input_encrypt"
                    value={this.state.encryptEnabled}
                    onValueChange={() =>
                      this.setState({
                        encryptEnabled: !this.state.encryptEnabled,
                      })
                    }
                  />
                  <Text style={{marginTop: 5, marginLeft: 5}}>Encrypt RSA</Text>
                </View>
                <View style={{flexDirection: 'row'}}>
                  <CheckBox
                    accessibilityLabel="show_webview"
                    value={this.state.showWebView}
                    onValueChange={() =>
                      this.setState({showWebView: !this.state.showWebView})
                    }
                  />
                  <Text style={{marginTop: 5, marginLeft: 5}}>
                    Toggle Webview Visibility
                  </Text>
                </View>
                <View style={{flexDirection: 'row'}}>
                  <CheckBox
                    accessibilityLabel="input_url_listener"
                    value={this.state.withUrlListener}
                    onValueChange={() =>
                      this.setState({
                        withUrlListener: !this.state.withUrlListener,
                      })
                    }
                  />
                  <Text style={{marginTop: 5, marginLeft: 5}}>
                    Add URL listener
                  </Text>
                </View>
                <View style={styles.buttonContainer}>
                  <TouchableOpacity
                    onPress={this.onInitHandler}
                    style={[{height: 50, flex: 1}]}>
                    <Text style={styles.button}>Initialize</Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    onPress={this.onExecuteHandler}
                    style={[{height: 50, flex: 1}]}>
                    <Text style={styles.button}>Execute</Text>
                  </TouchableOpacity>
                </View>
              </View>
            </View>

            {this.state.showWebView && (
              <WebView
                source={{uri: this.state.webViewUrl}}
                mediaPlaybackRequiresUserAction={true}
                style={styles.webview}
                // This deals with more than just url errors but its good enough for testing
                renderError={() => {
                  console.log(
                    `Error with ${this.state.webViewUrl}, ${this.state.webViewId}`,
                  );
                  Rokt.sendUrlFailure(
                    this.state.webViewId,
                    this.state.webViewUrl,
                    'This is a test',
                  );
                }}
              />
            )}

            <RoktEmbeddedView
              ref={this.placeholder1}
              placeholderName={this.state.targetElement1}
            />
            <RoktEmbeddedView
              ref={this.placeholder2}
              placeholderName={this.state.targetElement2}
            />
          </ScrollView>
          <Toast />
        </SafeAreaView>
      </>
    );
  }
}

const styles = StyleSheet.create({
  scrollView: {
    backgroundColor: Colors.lighter,
  },
  engine: {
    position: 'absolute',
    right: 0,
  },
  body: {
    backgroundColor: Colors.white,
  },
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
    flex: 1,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.black,
  },
  label: {
    fontWeight: '700',
  },
  multiLineText: {
    maxHeight: 80,
    borderColor: 'gray',
    borderWidth: 1,
  },
  footer: {
    color: Colors.dark,
    fontSize: 12,
    fontWeight: '600',
    padding: 4,
    paddingRight: 12,
    textAlign: 'right',
  },
  textInput: {
    height: 40,
    borderColor: 'gray',
    borderWidth: 1,
  },
  button: {
    flex: 1,
    backgroundColor: '#4ba9c8',
    borderColor: 'white',
    borderWidth: 1,
    borderRadius: 12,
    color: 'white',
    fontSize: 20,
    fontWeight: 'bold',
    padding: 9,
    textAlign: 'center',
  },
  buttonContainer: {
    marginTop: 10,
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'stretch',
  },
  horizontalContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'stretch',
  },
  webview: {
    marginTop: 20,
    height: deviceHeight / 4,
    width: deviceWidth,
    flex: 1,
    borderWidth: 2,
  },
});
