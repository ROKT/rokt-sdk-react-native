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

import { requireNativeComponent , StyleSheet, NativeEventEmitter, NativeModules, HostComponent, ViewProps, NativeModule} from 'react-native';
import React, {Component} from 'react';

const RoktEventManager = NativeModules.RoktEventManager as NativeModule

export interface HeightChangedEvent extends Event {
  height: string,
}

export interface MarginChangedEvent extends Event {
  marginTop: string,
  marginRight: string,
  marginLeft: string,
  marginBottom: string
}

export interface WidgetChangeEvent {
  selectedPlacement: string,
  height: string
}

export interface RoktEmbeddedViewProps {
  placeholderName: string
}

export interface RoktEmbeddedViewState {
  height: number,
  placeholderName: string,
  marginTop: number,
  marginRight: number,
  marginLeft: number,
  marginBottom: number
}

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

export class RoktEmbeddedView extends Component<RoktEmbeddedViewProps, RoktEmbeddedViewState> {

  subscription = eventManagerEmitter.addListener(
    'WidgetHeightChanges',
    (widgetChanges: WidgetChangeEvent) => {
      console.log
      if (widgetChanges.selectedPlacement == this.state.placeholderName) {
        this.setState({height: parseInt(widgetChanges.height)})
      } 
    }
  );

    constructor(props: RoktEmbeddedViewProps){
        super(props);

        this.state = { height: 0, placeholderName: this.props.placeholderName, marginTop: 0, marginRight: 0, marginLeft: 0, marginBottom: 0 };
    }

    override render() {
      return (
          <WidgetNativeComponent style={[styles.widget, {height: this.state.height}]}/>
      );
    }

    override componentWillUnmount(){
      this.subscription.remove();
    }

  }

  const WidgetNativeComponent: HostComponent<ViewProps> = requireNativeComponent('RoktNativeWidget')

  const styles = StyleSheet.create({
    widget: {
        flex: 1,
        backgroundColor: 'white' },
    });
  
  export default RoktEmbeddedView;