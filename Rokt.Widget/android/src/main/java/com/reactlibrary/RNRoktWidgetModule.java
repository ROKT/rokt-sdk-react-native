
package com.reactlibrary;

import android.app.Activity;
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

public class RNRoktWidgetModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    RNRoktWidgetModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @ReactMethod
    public void initialize(String roktTagId, String appVersion) {
        Activity currentActivity = getCurrentActivity();
        Rokt.INSTANCE.init(roktTagId, appVersion, currentActivity);
    }

    @ReactMethod
    public void execute(final String viewName, final ReadableMap attributes, final ReadableMap placeholders, final Callback onLoad) {
        final Map<String, WeakReference<Widget>> placeholderMap = new HashMap<>();

        UIManagerModule uiManager = reactContext.getNativeModule(UIManagerModule.class);
        uiManager.addUIBlock(new UIBlock() {
            @Override
            public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                for (Map.Entry<String, Object> entry : placeholders.toHashMap().entrySet()) {
                    int tag = ((Double) entry.getValue()).intValue();
                    View view = nativeViewHierarchyManager.resolveView(tag);
                    if (view instanceof Widget){
                        placeholderMap.put(entry.getKey(), new WeakReference(view));
                    }
                }

                Rokt.INSTANCE.execute(viewName, new HashMap(attributes.toHashMap()),
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
}






