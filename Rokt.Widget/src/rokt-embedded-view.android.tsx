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

import { StyleSheet, Alert, View } from 'react-native';
import React, { Component } from 'react';
import RoktNativeWidgetNativeComponent from './RoktNativeWidgetNativeComponent';

/**
 * PUBLIC API: Props that users of RoktEmbeddedView can set
 * This is simplified to only expose the placeholderName prop to users
 */
export interface RoktEmbeddedViewProps {
  // Placeholder name to use
  placeholderName: string;
}

/**
 * INTERNAL: State managed by the component to handle native events
 */
export interface RoktEmbeddedViewState {
  height: number;
  placeholderName: string;
  marginTop: number;
  marginRight: number;
  marginLeft: number;
  marginBottom: number;
}

const styles = StyleSheet.create({
  widget: {
    flex: 1,
    backgroundColor: 'transparent'
  }
});

/**
 * RoktEmbeddedView is a wrapper component for the native RoktNativeWidget.
 * It handles the native events internally and provides a simpler API for React Native apps.
 *
 * This component only exposes the placeholderName prop to users, hiding all the internal complexity.
 */
export class RoktEmbeddedView extends Component<RoktEmbeddedViewProps, RoktEmbeddedViewState> {
  constructor(props: RoktEmbeddedViewProps) {
    super(props);
    console.log('[ROKT] RoktEmbeddedView constructor called ***');

    this.state = { height: 0, placeholderName: this.props.placeholderName, marginTop: 0, marginRight: 0, marginLeft: 0, marginBottom: 0 };
  }

  /**
   * Handles the height changed event from the native component
   * This is an internal implementation detail not exposed to users
   */
  private handleHeightChanged = (event: any) => {
    if (event && event.nativeEvent && event.nativeEvent.height) {
      this.setState({ height: parseInt(event.nativeEvent.height) });
    }
  }

  /**
   * Handles the margin changed event from the native component
   * This is an internal implementation detail not exposed to users
   */
  private handleMarginChanged = (event: any) => {
    if (event && event.nativeEvent) {
      const { marginTop, marginLeft, marginRight, marginBottom } = event.nativeEvent;
      this.setState({
        marginTop: parseInt(marginTop || '0'),
        marginLeft: parseInt(marginLeft || '0'),
        marginRight: parseInt(marginRight || '0'),
        marginBottom: parseInt(marginBottom || '0')
      });
    }
  }

  override componentDidMount() {
    console.log('[ROKT] RoktEmbeddedView componentDidMount:::');
  }

  override render() {
    console.log('[ROKT] RoktEmbeddedView render called');
    try {
      // Get the placeholderName from props
      const { placeholderName } = this.props;

      console.log('[ROKT] Rendering RoktNativeWidget with placeholderName=>', placeholderName);
      // Return the native component with the props
      return (
        <RoktNativeWidgetNativeComponent
          placeholderName={placeholderName}
          style={[
            styles.widget,
            {
              height: this.state.height,
              marginTop: this.state.marginTop,
              marginLeft: this.state.marginLeft,
              marginRight: this.state.marginRight,
              marginBottom: this.state.marginBottom,
            },
          ]}
          onWidgetHeightChanged={this.handleHeightChanged}
          onWidgetMarginChanged={this.handleMarginChanged}
        />
      );
    } catch (error) {
      console.error('[ROKT] Error rendering RoktEmbeddedView:', error);
      return null;
    }
  }
}

export default RoktEmbeddedView;