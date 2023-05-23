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

import { requireNativeComponent, StyleSheet } from 'react-native';
import React, { Component } from 'react';
import { HostComponent } from 'react-native';
import { ViewProps } from 'react-native';

export interface HeightChangedEvent extends Event {
  height: string,
}

export interface MarginChangedEvent extends Event {
  marginTop: string,
  marginRight: string,
  marginLeft: string,
  marginBottom: string
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

export interface WidgetNativeComponentProps extends ViewProps {
  onWidgetHeightChanged: (event: React.SyntheticEvent) => void,
  onWidgetMarginChanged: (event: React.SyntheticEvent) => void
}

class RoktEmbeddedView extends Component<RoktEmbeddedViewProps, RoktEmbeddedViewState> {

  constructor(props: RoktEmbeddedViewProps) {
    super(props);

    this.state = { height: 0, placeholderName: this.props.placeholderName, marginTop: 0, marginRight: 0, marginLeft: 0, marginBottom: 0 };
  }

  onWidgetHeightChanged = (event: React.SyntheticEvent) => {
    const heightChangedEvent = event.nativeEvent as HeightChangedEvent
    this.setState({ height: parseInt(heightChangedEvent.height) });
  }

  onWidgetMarginChanged = (event: React.SyntheticEvent) => {
    const marginChangedEvent = event.nativeEvent as MarginChangedEvent
    this.setState({
      marginTop: parseInt(marginChangedEvent.marginTop),
      marginLeft: parseInt(marginChangedEvent.marginLeft),
      marginRight: parseInt(marginChangedEvent.marginRight),
      marginBottom: parseInt(marginChangedEvent.marginBottom)
    })
  }

  override render() {
    return (
      <WidgetNativeComponent style={[styles.widget, { height: this.state.height }, { marginTop: this.state.marginTop },
      { marginLeft: this.state.marginLeft }, { marginRight: this.state.marginRight }, { marginBottom: this.state.marginBottom }]} onWidgetHeightChanged={this.onWidgetHeightChanged}
        onWidgetMarginChanged={this.onWidgetMarginChanged} />
    );
  }
}

const WidgetNativeComponent: HostComponent<WidgetNativeComponentProps> = requireNativeComponent('RoktNativeWidget')

const styles = StyleSheet.create({
  widget: {
    flex: 1,
    backgroundColor: 'white'
  },
});

export default RoktEmbeddedView;