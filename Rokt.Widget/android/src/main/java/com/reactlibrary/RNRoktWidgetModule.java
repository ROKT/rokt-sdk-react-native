
package com.reactlibrary;

import android.app.Activity;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.NativeViewHierarchyManager;
import com.facebook.react.uimanager.UIBlock;
import com.facebook.react.uimanager.UIManagerModule;
import com.rokt.roktsdk.Rokt;
import com.rokt.roktsdk.Widget;

import java.lang.ref.WeakReference;
import java.util.HashMap;
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
    private final String TAG = "RoktWidget";

    RNRoktWidgetModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @ReactMethod
    public void initialize(String roktTagId, String appVersion) {

        Activity currentActivity = getCurrentActivity();
        if (currentActivity != null && appVersion != null && roktTagId != null) {
            Rokt.INSTANCE.init(roktTagId, appVersion, currentActivity);
        } else {
            Log.d(TAG, "Activity, roktTagId and AppVersion cannot be null");
        }
    }

    @ReactMethod
    public void execute(final String viewName, final ReadableMap attributes, final ReadableMap placeholders, final Callback onLoad) {
        if (viewName == null) {
            Log.d(TAG, "Execute failed. ViewName cannot be null");
            return;
        }

        final Map<String, WeakReference<Widget>> placeholderMap = new HashMap<>();

        UIManagerModule uiManager = reactContext.getNativeModule(UIManagerModule.class);
        uiManager.addUIBlock(new UIBlock() {
            @Override
            public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                for (Map.Entry<String, Object> entry : placeholders.toHashMap().entrySet()) {
                    if (entry.getValue() != null && entry.getValue() instanceof Double) {
                        int tag = ((Double) entry.getValue()).intValue();
                        View view = nativeViewHierarchyManager.resolveView(tag);
                        if (view instanceof Widget) {
                            placeholderMap.put(entry.getKey(), new WeakReference(view));
                        }
                    }
                }


                Rokt.INSTANCE.execute(viewName, convertAttributesToMapOfStrings(attributes),

                new Rokt.RoktCallback() {
                    @Override
                    public void onLoad() {
                        if (onLoad != null) {
                            onLoad.invoke();
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
                }, placeholderMap);
            }
        });
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


    private Map<String, String> convertAttributesToMapOfStrings(final ReadableMap attributes){
        if (attributes != null) {
            Map<String, Object> map = attributes.toHashMap();
            Map<String,String> newMap = new HashMap<String,String>();
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                if(entry.getValue() instanceof String){
                    newMap.put(entry.getKey(), (String) entry.getValue());
                }
            }
            return newMap;
        }

        return null;
    }
}
