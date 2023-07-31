package com.rokt.reactlibrary;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.rokt.roktsdk.RoktWidgetDimensionCallBack;
import com.rokt.roktsdk.Widget;

import java.util.Map;

/**
 * Copyright 2020 Rokt Pte Ltd
 *
 * Licensed under the Rokt Software Development Kit (SDK) Terms of Use
 * Version 2.0 (the "License");
 *
 * You may not use this file except in compliance with the License.
 *
 * You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
*/

public class RoktEmbeddedViewManager extends ViewGroupManager<Widget> {
    @Override
    public String getName() {
        return "RoktNativeWidget";
    }

    @Override
    protected Widget createViewInstance(ThemedReactContext reactContext) {
        Widget widget = new Widget(reactContext);
        setUpWidgetListeners(widget);
        return widget;
    }

    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>builder()
                .put("onWidgetHeightChanged",
                        MapBuilder.of("registrationName", "onWidgetHeightChanged"))
                .put("onWidgetMarginChanged",
                        MapBuilder.of("registrationName", "onWidgetMarginChanged"))
                .build();
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return false;
    }
    private void setUpWidgetListeners(final Widget widget) {
        widget.registerDimensionListener(new RoktWidgetDimensionCallBack() {

            @Override
            public void onHeightChanged(int height) {
                changeHeight((ReactContext) widget.getContext(), height, widget.getId());
            }

            @Override
            public void onMarginChanged(int start, int top, int end, int bottom) {
                changeMargin((ReactContext) widget.getContext(), widget.getId(), start, top, end, bottom);
            }
        });
    }

    void changeHeight(ReactContext context, int height, int id) {
        WritableMap event = Arguments.createMap();
        event.putString("height", Integer.toString(height));
        context.getJSModule(RCTEventEmitter.class)
                .receiveEvent(id, "onWidgetHeightChanged", event);
    }

    void changeMargin(ReactContext context, int id, int start, int top, int end, int bottom) {
        WritableMap event = Arguments.createMap();
        event.putString("marginLeft", Integer.toString(start));
        event.putString("marginTop", Integer.toString(top));
        event.putString("marginRight", Integer.toString(end));
        event.putString("marginBottom", Integer.toString(bottom));
        context.getJSModule(RCTEventEmitter.class)
                .receiveEvent(id, "onWidgetMarginChanged", event);
    }
}
