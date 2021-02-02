package com.reactlibrary;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
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
        return new Widget(reactContext);
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
}
