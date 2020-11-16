package com.reactlibrary;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.rokt.roktsdk.Widget;

import java.util.Map;

public class RoktWidgetViewManager extends ViewGroupManager<Widget> {
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
                .build();
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return false;
    }
}
