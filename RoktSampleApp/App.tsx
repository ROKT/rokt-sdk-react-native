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
  EmitterSubscription,
  findNodeHandle,
  NativeEventEmitter,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import CheckBox from '@react-native-community/checkbox';
import Toast from 'react-native-toast-message';
import {isEmpty, isNotEmpty, isValidJson} from './utils/text-utils';
import {
  DEFAULT_ATTRIBUTES,
  DEFAULT_COUNTRY,
  DEFAULT_TAG_ID,
  DEFAULT_VIEW_NAME,
} from './utils/rokt-constants';
import {Rokt, RoktEmbeddedView, RoktEventManager} from '@rokt/react-native-sdk';

const Colors = {
  white: '#ffffff',
  lighter: '#f3f3f3',
  light: '#dae1e7',
  dark: '#444444',
  darker: '#222222',
  black: '#000000',
};

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

type RoktEmbeddedViewRef = React.ComponentRef<typeof RoktEmbeddedView>;

interface Props {}

interface State {
  tagId: string;
  viewName: string;
  country: string;
  targetElement1: string;
  targetElement2: string;
  attributes: string;
  stageEnabled: boolean;
}

export default class App extends Component<Props, State> {
  private placeholder1 = React.createRef<RoktEmbeddedViewRef>();
  private placeholder2 = React.createRef<RoktEmbeddedViewRef>();

  private eventSubscription: EmitterSubscription;

  constructor(props: Props) {
    super(props);

    let attributes = JSON.stringify(DEFAULT_ATTRIBUTES);

    this.state = {
      tagId: DEFAULT_TAG_ID,
      viewName: DEFAULT_VIEW_NAME,
      country: DEFAULT_COUNTRY,
      targetElement1: 'Location1',
      targetElement2: 'Location2',
      attributes: attributes,
      stageEnabled: false,
    };

    this.eventSubscription = eventManagerEmitter.addListener(
      'RoktEvents',
      data => {
        console.log(`*** ROKT EVENT *** ${JSON.stringify(data)}`);
        // Check if the event is CartItemInstantPurchase
        if (data.event === 'CartItemInstantPurchase') {
          console.log(
            'CartItemInstantPurchase event received, calling purchaseFinalized',
          );
          // Call purchaseFinalized with the required parameters
          // placementId, catalogItemId, and status (true for successful purchase)
          Rokt.purchaseFinalized(data.placementId, data.catalogItemId, true);
        } else if (data.event === 'CartItemInstantPurchaseInitiated') {
          console.log('Shoppable: Purchase initiated', data.catalogItemId);
        } else if (data.event === 'CartItemInstantPurchaseFailure') {
          console.log('Shoppable: Purchase failed', data.error);
        } else if (data.event === 'CartItemDevicePay') {
          console.log('Shoppable: Device pay', data.paymentProvider);
        } else if (data.event === 'InstantPurchaseDismissal') {
          console.log('Shoppable: Dismissal');
        }
      },
    );
  }

  componentWillUnmount() {
    this.eventSubscription.remove();
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

  showToast = (message: string) => {
    Toast.show({
      text1: 'Invalid form',
      text2: message,
      type: 'error',
      position: 'bottom',
      autoHide: true,
    });
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

    const placeholders: {[key: string]: number} = {};
    const nodeHandle1 = findNodeHandle(this.placeholder1.current);
    if (nodeHandle1 !== null) {
      placeholders[this.state.targetElement1] = nodeHandle1;
    }
    const nodeHandle2 = findNodeHandle(this.placeholder2.current);
    if (nodeHandle2 !== null) {
      placeholders[this.state.targetElement2] = nodeHandle2;
    }

    if (isEmpty(this.state.viewName)) {
      this.showToast('View Name cannot be empty');
      return;
    }

    Rokt.selectPlacements(this.state.viewName, attributes, placeholders);
    console.log('Select Placements');
  };

  onShoppableAdsHandler = () => {
    var stateCopy = JSON.parse(JSON.stringify(this.state));
    if (!isValidJson(stateCopy.attributes)) {
      this.showToast('Attributes must be valid JSON');
      return;
    }
    var attributes = JSON.parse(stateCopy.attributes);
    attributes.country = this.state.country;

    if (isEmpty(this.state.viewName)) {
      this.showToast('View Name cannot be empty');
      return;
    }

    Rokt.selectShoppableAds(this.state.viewName, attributes);
    console.log('Select Shoppable Ads');
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
                  onChangeText={tagId => this.setState({tagId})}
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
                      onChangeText={viewName => this.setState({viewName})}
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
                      onChangeText={country => this.setState({country})}
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
                  onChangeText={targetElement1 =>
                    this.setState({targetElement1})
                  }
                />
                <Text style={[styles.label, {color: Colors.black}]}>
                  Target Element
                </Text>
                <TextInput
                  style={styles.textInput}
                  value={this.state.targetElement2}
                  onChangeText={targetElement2 =>
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
                  onChangeText={attributes => {
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
                  <TouchableOpacity
                    onPress={this.onShoppableAdsHandler}
                    style={[{height: 50, flex: 1}]}>
                    <Text style={styles.button}>Shoppable Ads</Text>
                  </TouchableOpacity>
                </View>
              </View>
            </View>

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
});
