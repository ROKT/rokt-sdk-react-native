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

import {
  StyleSheet,
  NativeEventEmitter,
  NativeModules,
  HostComponent,
  ViewProps,
  NativeModule,
} from "react-native";
import React, { Component } from "react";
import RoktNativeWidgetNativeComponent from "./RoktNativeWidgetNativeComponent";

const RoktEventManager = NativeModules.RoktEventManager as NativeModule;

export interface HeightChangedEvent extends Event {
  height: string;
}

export interface MarginChangedEvent extends Event {
  marginTop: string;
  marginRight: string;
  marginLeft: string;
  marginBottom: string;
}

export interface WidgetChangeEvent {
  selectedPlacement: string;
  height: string;
}

export interface RoktEmbeddedViewProps {
  placeholderName: string;
}

export interface RoktEmbeddedViewState {
  height: number;
  placeholderName: string;
  marginTop: number;
  marginRight: number;
  marginLeft: number;
  marginBottom: number;
}

// Define the native component props interface
interface RoktNativeWidgetProps extends ViewProps {
  placeholderName?: string;
  onWidgetHeightChanged?: (event: HeightChangedEvent) => void;
  onWidgetMarginChanged?: (event: MarginChangedEvent) => void;
}

// Always use the codegen component - it handles both Fabric and interop automatically
// In New Arch: Uses RoktNativeWidgetComponentView (Fabric)
// In Old Arch: Uses interop with RoktNativeWidget ViewManager
const WidgetNativeComponent =
  RoktNativeWidgetNativeComponent as HostComponent<RoktNativeWidgetProps>;

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

export class RoktEmbeddedView extends Component<
  RoktEmbeddedViewProps,
  RoktEmbeddedViewState
> {
  subscription = eventManagerEmitter.addListener(
    "WidgetHeightChanges",
    (widgetChanges: WidgetChangeEvent) => {
      if (widgetChanges.selectedPlacement == this.state.placeholderName) {
        this.setState({ height: parseInt(widgetChanges.height) });
      }
    },
  );

  constructor(props: RoktEmbeddedViewProps) {
    super(props);

    this.state = {
      height: 0,
      placeholderName: this.props.placeholderName,
      marginTop: 0,
      marginRight: 0,
      marginLeft: 0,
      marginBottom: 0,
    };
  }

  override render() {
    return (
      <WidgetNativeComponent
        style={[styles.widget, { height: this.state.height }]}
        placeholderName={this.state.placeholderName}
        onWidgetHeightChanged={(event) => {
          if (event.height) {
            this.setState({ height: parseInt(event.height) });
          }
        }}
        onWidgetMarginChanged={(event) => {
          this.setState({
            marginTop: parseInt(event.marginTop || "0"),
            marginRight: parseInt(event.marginRight || "0"),
            marginLeft: parseInt(event.marginLeft || "0"),
            marginBottom: parseInt(event.marginBottom || "0"),
          });
        }}
      />
    );
  }

  override componentWillUnmount() {
    this.subscription.remove();
  }
}

const styles = StyleSheet.create({
  widget: {
    // Do NOT use `flex: 1` here. It expands to `flexBasis: 0%`, which takes
    // precedence over `height` on the parent's main axis, so inside any
    // auto-height column parent the widget collapses to 0 and the placement is
    // never visible even though the SDK selected it and reported its height.
    // `alignSelf: "stretch"` gives the full available width without touching the
    // main axis, leaving the measured `height` free to apply.
    alignSelf: "stretch",
    backgroundColor: "transparent",
    overflow: "hidden",
  },
});

export default RoktEmbeddedView;
