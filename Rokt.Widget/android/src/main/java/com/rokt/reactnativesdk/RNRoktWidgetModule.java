
package com.rokt.reactnativesdk;

import android.app.Activity;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.uimanager.NativeViewHierarchyManager;
import com.facebook.react.uimanager.UIBlock;
import com.facebook.react.uimanager.UIManagerModule;
import com.rokt.roktsdk.Rokt;
import com.rokt.roktsdk.Rokt.RoktEventHandler;
import com.rokt.roktsdk.Widget;

import java.lang.ref.WeakReference;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import android.content.Context;
import android.graphics.Typeface;
import android.content.res.AssetManager;
import java.lang.ref.WeakReference;

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

public class RNRoktWidgetModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private RoktEventHandler roktEventHandler;
    private Boolean debug = false;
    private final Set<Typeface> typefacesSet;

    Map<Long, Rokt.RoktCallback> listeners = new LinkedHashMap<Long, Rokt.RoktCallback>() {
        @Override
        protected boolean removeEldestEntry(Map.Entry<Long, Rokt.RoktCallback> eldest) {
            int MAX_LISTENERS = 5;
            return this.size() > MAX_LISTENERS;
        }
    };

    RNRoktWidgetModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.typefacesSet = new HashSet<Typeface>();
    }

    @ReactMethod
    public void initialize(String roktTagId, String appVersion, final ReadableArray fontPostScriptNames) {
        Activity currentActivity = getCurrentActivity();
        if (currentActivity != null && appVersion != null && roktTagId != null) {
            Rokt.INSTANCE.setFrameworkType(Rokt.SdkFrameworkType.ReactNative.INSTANCE);
            Rokt.INSTANCE.init(roktTagId, appVersion, currentActivity, true, readableArrayToSetOfStrings(fontPostScriptNames));
        } else {
            logDebug("Activity, roktTagId and AppVersion cannot be null");
        }
    }

    @ReactMethod
    public void execute(final String viewName, final ReadableMap attributes, final ReadableMap placeholders, final ReadableMap fontsMap) {
        if (viewName == null) {
            logDebug("Execute failed. ViewName cannot be null");
            return;
        }
        Activity currentActivity = getCurrentActivity();
        final Map<String, WeakReference<Typeface>> typefaceMap = new HashMap<>();
        if (currentActivity != null) {
            typefaceMap.putAll(retrieveFonts(readableMapToMapOfStrings(fontsMap), currentActivity));
        }

        UIManagerModule uiManager = reactContext.getNativeModule(UIManagerModule.class);
        uiManager.addUIBlock(new UIBlock() {
            @Override
            public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                Rokt.INSTANCE.execute(viewName, readableMapToMapOfStrings(attributes), createRoktCallback(), safeUnwrapPlaceholders(placeholders, nativeViewHierarchyManager), typefaceMap);
            }
        });
    }

    @ReactMethod
    public void execute2Step(final String viewName, final ReadableMap attributes, final ReadableMap placeholders, final ReadableMap fontsMap) {
        if (viewName == null) {
            logDebug("Execute failed. ViewName cannot be null");
            return;
        }
        Activity currentActivity = getCurrentActivity();
        final Map<String, WeakReference<Typeface>> typefaceMap = new HashMap<>();
        if (currentActivity != null) {
            typefaceMap.putAll(retrieveFonts(readableMapToMapOfStrings(fontsMap), currentActivity));
        }

        UIManagerModule uiManager = reactContext.getNativeModule(UIManagerModule.class);
        uiManager.addUIBlock(new UIBlock() {
            @Override
            public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                Rokt.INSTANCE.execute2Step(viewName, readableMapToMapOfStrings(attributes), createRoktCallback(), safeUnwrapPlaceholders(placeholders, nativeViewHierarchyManager), new Rokt.RoktEventCallback() {
                    @Override
                    public void onEvent(Rokt.RoktEventType roktEventType, final Rokt.RoktEventHandler roktEventHandler) {
                        setRoktEventHandler(roktEventHandler);
                        if (roktEventType == Rokt.RoktEventType.FirstPositiveEngagement) {
                            logDebug("onFirstPositiveEvent was fired");
                            sendEvent(reactContext, "FirstPositiveResponse", null);
                        }
                    }
                }, typefaceMap);
            }
        });
    }


    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
        if (reactContext != null) {
            reactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        }
    }

    @ReactMethod
    public void setFulfillmentAttributes(final ReadableMap attributes) {
        if (this.roktEventHandler != null) {
            Map<String, String> fulfillmentAttributes = readableMapToMapOfStrings(attributes);
            if (fulfillmentAttributes != null) {
                roktEventHandler.setFulfillmentAttributes(fulfillmentAttributes);
                logDebug("Calling setFulfillmentAttributes");
            } else {
                logDebug("Fulfillment attributes must be a map of Strings");
            }
        } else {
            logDebug("RoktEventHandler is null, make sure you run execute2Step before calling setFulfillmentAttributes");
        }
    }

    private void setRoktEventHandler(RoktEventHandler roktEventHandler) {
        this.roktEventHandler = roktEventHandler;
    }

    @Override
    public String getName() {
        return "RNRoktWidget";
    }

    @ReactMethod
    public void setEnvironmentToStage() {
        Rokt.INSTANCE.setEnvironment(Rokt.Environment.Stage.INSTANCE);
    }

    @ReactMethod
    public void setEnvironmentToProd() {
        Rokt.INSTANCE.setEnvironment(Rokt.Environment.Prod.INSTANCE);
    }

    @ReactMethod
    public void toggleDebug(Boolean enabled) {
        this.debug = enabled;
    }

    private void logDebug(String message) {
        if (debug) {
            Log.d("Rokt", message);
        }
    }

    private Map<String, String> readableMapToMapOfStrings(final ReadableMap attributes) {
        if (attributes != null) {
            Map<String, Object> map = attributes.toHashMap();
            Map<String, String> newMap = new HashMap<String, String>();
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                if (entry.getValue() instanceof String) {
                    newMap.put(entry.getKey(), (String) entry.getValue());
                }
            }
            return newMap;
        }

        return null;
    }

    private Set<String> readableArrayToSetOfStrings(final ReadableArray array) {
        if (array == null) return null;
        return array
                .toArrayList()
                .stream()
                .filter(s -> s instanceof String)
                .map(s -> (String) s)
                .collect(Collectors.toSet());
    }

    private Rokt.RoktCallback createRoktCallback() {
        Rokt.RoktCallback callback = new Rokt.RoktCallback() {
            @Override
            public void onLoad() {
                sendCallback("onLoad", null);
            }

            @Override
            public void onUnload(@NonNull Rokt.UnloadReasons unloadReasons) {
                sendCallback("onUnLoad", unloadReasons.toString());
            }

            @Override
            public void onShouldShowLoadingIndicator() {
                sendCallback("onShouldShowLoadingIndicator", null);
            }

            @Override
            public void onShouldHideLoadingIndicator() {
                sendCallback("onShouldHideLoadingIndicator", null);
            }
        };
        listeners.put(System.currentTimeMillis(), callback);
        return callback;
    }

    private void sendCallback(final String eventValue, @Nullable final String reason) {
        WritableMap params = Arguments.createMap();
        params.putString("callbackValue", eventValue);
        if (reason != null) {
            params.putString("reason", reason);
        }
        sendEvent(reactContext, "RoktCallback", params);
    }

    private Map<String, WeakReference<Widget>> safeUnwrapPlaceholders(final ReadableMap placeholders, final NativeViewHierarchyManager nativeViewHierarchyManager) {
        final Map<String, WeakReference<Widget>> placeholderMap = new HashMap<>();

        if (placeholders != null) {
            for (Map.Entry<String, Object> entry : placeholders.toHashMap().entrySet()) {
                if (entry.getValue() instanceof Double) {
                    int tag = ((Double) entry.getValue()).intValue();
                    View view = nativeViewHierarchyManager.resolveView(tag);
                    if (view instanceof Widget) {
                        placeholderMap.put(entry.getKey(), new WeakReference(view));
                    }
                }
            }
        }

        return placeholderMap;
    }

    private Map<String, WeakReference<Typeface>> retrieveFonts(final Map<String, String> fontNameMap, final Context context) {
        final String FONTS_ASSET_PATH = "fonts/";
        try {
            AssetManager am = context.getAssets();
            Map<String, WeakReference<Typeface>> typefaceMap = new HashMap<>();
            fontNameMap.forEach((k, v) -> {
                Typeface tf = Typeface.createFromAsset(am, FONTS_ASSET_PATH + v);
                typefacesSet.add(tf);
                typefaceMap.put(k, new WeakReference<Typeface>(tf));
            });
            return typefaceMap;
        } catch (RuntimeException e) {
            return new HashMap<String, WeakReference<Typeface>>();
        }
    }
}