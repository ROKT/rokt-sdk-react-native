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
  requireNativeComponent,
  StyleSheet,
  NativeEventEmitter,
  NativeModules,
  HostComponent,
  ViewProps,
  NativeModule,
  UIManager,
} from "react-native";
import React, { Component } from "react";

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

// Architecture detection - Updated for RN 0.80+ compatibility
// In RN 0.80+, check for Fabric renderer using a more reliable method
const isNewArchitecture = (() => {
  // Check if Fabric renderer is enabled by looking at UIManager properties
  // This is a safer approach that works in RN 0.80+
  const hasFabricUIManager =
    UIManager &&
    typeof UIManager.hasViewManagerConfig === "function" &&
    UIManager.hasViewManagerConfig("RCTView");

  if (hasFabricUIManager) {
    return true;
  }

  // Fallback: check TurboModule presence (less reliable in 0.80+)
  const turboModuleCheck =
    (NativeModules as { RNRoktWidget?: unknown }).RNRoktWidget == null;
  return turboModuleCheck;
})();

// Conditional component loading based on architecture
let WidgetNativeComponent: HostComponent<RoktNativeWidgetProps>;

if (isNewArchitecture) {
  try {
    // Try to import the new architecture component
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const NativeComponent = require("./RoktNativeWidgetNativeComponent") as {
      default: HostComponent<RoktNativeWidgetProps>;
    };
    WidgetNativeComponent = NativeComponent.default;
  } catch (error) {
    WidgetNativeComponent = requireNativeComponent("RoktNativeWidget");
  }
} else {
  WidgetNativeComponent = requireNativeComponent("RoktNativeWidget");
}

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
    flex: 1,
    backgroundColor: "transparent",
    overflow: "hidden",
  },
});

export default RoktEmbeddedView;
