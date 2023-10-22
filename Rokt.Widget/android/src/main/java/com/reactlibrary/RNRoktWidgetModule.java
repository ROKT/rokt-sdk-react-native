
package com.reactlibrary;

import android.app.Activity;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.uimanager.NativeViewHierarchyManager;
import com.facebook.react.uimanager.UIBlock;
import com.facebook.react.uimanager.UIManagerModule;
import com.rokt.roktsdk.Rokt;
import com.rokt.roktsdk.Rokt.RoktEventHandler;
import com.rokt.roktsdk.Widget;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.LinkedHashMap;
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

public class RNRoktWidgetModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private RoktEventHandler roktEventHandler;
    private Boolean debug = false;

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
    }

    @ReactMethod
    public void initialize(String roktTagId, String appVersion) {
        Activity currentActivity = getCurrentActivity();
        if (currentActivity != null && appVersion != null && roktTagId != null) {
            Rokt.INSTANCE.setFrameworkType(Rokt.SdkFrameworkType.ReactNative.INSTANCE);
            Rokt.INSTANCE.init(roktTagId, appVersion, currentActivity);
        } else {
            logDebug("Activity, roktTagId and AppVersion cannot be null");
        }
    }

    @ReactMethod
    public void execute(final String viewName, final ReadableMap attributes, final ReadableMap placeholders, final Callback onLoad) {
        if (viewName == null) {
            logDebug("Execute failed. ViewName cannot be null");
            return;
        }

        UIManagerModule uiManager = reactContext.getNativeModule(UIManagerModule.class);
        uiManager.addUIBlock(new UIBlock() {
            @Override
            public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                WeakReference<Callback> callBack = new WeakReference<>(onLoad);
                Rokt.INSTANCE.execute(viewName, readableMapToMapOfStrings(attributes), createRoktCallback(callBack), safeUnwrapPlaceholders(placeholders, nativeViewHierarchyManager));
            }
        });
    }

    @ReactMethod
    public void execute2Step(final String viewName, final ReadableMap attributes, final ReadableMap placeholders, final Callback onLoad) {
        if (viewName == null) {
            logDebug("Execute failed. ViewName cannot be null");
            return;
        }

        UIManagerModule uiManager = reactContext.getNativeModule(UIManagerModule.class);
        uiManager.addUIBlock(new UIBlock() {
            @Override
            public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                WeakReference<Callback> callBack = new WeakReference<>(onLoad);
                Rokt.INSTANCE.execute2Step(viewName, readableMapToMapOfStrings(attributes), createRoktCallback(callBack), safeUnwrapPlaceholders(placeholders, nativeViewHierarchyManager), new Rokt.RoktEventCallback() {
                    @Override
                    public void onEvent(Rokt.RoktEventType roktEventType, final Rokt.RoktEventHandler roktEventHandler) {
                        setRoktEventHandler(roktEventHandler);
                        if (roktEventType == Rokt.RoktEventType.FirstPositiveEngagement) {
                            logDebug("onFirstPositiveEvent was fired");
                            sendEvent(reactContext, "FirstPositiveResponse", null);
                        }
                    }
                });
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

    private Rokt.RoktCallback createRoktCallback(final WeakReference<Callback> onLoad) {
        Rokt.RoktCallback callback = new Rokt.RoktCallback() {
            @Override
            public void onLoad() {
                if (onLoad != null) {
                    Callback onLoadCallback = onLoad.get();
                    if (onLoadCallback != null) {
                        onLoadCallback.invoke();
                    }
                }
            }

            @Override
            public void onUnload(@NonNull Rokt.UnloadReasons unloadReasons) {
                if (unloadReasons != null) {

                }
            }

            @Override
            public void onShouldShowLoadingIndicator() {
            }

            @Override
            public void onShouldHideLoadingIndicator() {
            }
        };
        listeners.put(System.currentTimeMillis(), callback);
        return callback;
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
}