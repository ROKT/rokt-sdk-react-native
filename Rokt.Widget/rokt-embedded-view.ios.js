/**
 * rokt-embedded-view.js
 * 
 * Licensed under the Rokt Software Development Kit (SDK) Terms of Use
 * Version 2.0 (the "License");
 * 
 * You may not use this file except in compliance with the License.
 * 
 * You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
 */

import { requireNativeComponent , StyleSheet, NativeEventEmitter, NativeModules} from 'react-native';
import React, {Component} from 'react';
const { RoktEventManager } = NativeModules;

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

class RoktEmbeddedView extends Component {

  subscription = eventManagerEmitter.addListener(
    'WidgetHeightChanges',
    (widgetChanges) => {
      console.log
      if (widgetChanges.selectedPlacement == this.state.placeholderName) {
        this.state.height = parseInt(widgetChanges.height);
        this.forceUpdate();
      } 
    }
  );

    constructor(props){
        super(props);

         this.state = { height: 0,  placeholderName: this.props.placeholderName};
    }

    render() {
      return (
          <WidgetNativeComponent style={[styles.widget, {height: this.state.height}]}/>
      );
    }

    componentWillUnmount(){
      this.subscription.remove();
    }

  }

  const WidgetNativeComponent = requireNativeComponent('RoktNativeWidget')

  const styles = StyleSheet.create({
    widget: {
        flex: 1,
        backgroundColor: 'white' },
    });
  
  export default RoktEmbeddedView;


