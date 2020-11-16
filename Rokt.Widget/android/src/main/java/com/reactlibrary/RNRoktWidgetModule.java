
package com.reactlibrary;

import android.app.Activity;
import android.os.Handler;
import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.queue.MessageQueueThreadImpl;
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
    private MessageQueueThreadImpl nativeModulesThread;

    public RNRoktWidgetModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @ReactMethod
    public void initialize(String roktTagId, String appVersion) {
        Activity currentActivity = getCurrentActivity();
        Rokt.INSTANCE.init("1_67700f1c96584c97be7e540a8358e830", appVersion, currentActivity);
    }

    private Handler backgroundHandler;
    private int tag = 0;
    @ReactMethod
    public void execute(final String viewName, final ReadableMap attributes, final ReadableMap p, final Callback onLoad) {
        final Map<String, WeakReference<Widget>> placeholders = new HashMap();

        UIManagerModule uiManager = reactContext.getNativeModule(UIManagerModule.class);
        uiManager.addUIBlock(new UIBlock() {
            @Override
            public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                for (Map.Entry<String, Object> entry : p.toHashMap().entrySet()) {
                    String key = entry.getKey();
                    Double value = (Double) entry.getValue();
                    View view = nativeViewHierarchyManager.resolveView(value.intValue());
                    tag = value.intValue();
                    placeholders.put(key, new WeakReference(view));
                }
                runIT(viewName, attributes, placeholders, onLoad);
            }
        });

    }


    private void runIT(final String viewName, final ReadableMap attributes, final Map<String, WeakReference<Widget>> placeholders, final Callback onLoad) {
        Map<String, String> attributesMap = new HashMap(attributes.toHashMap());

        Rokt.INSTANCE.execute("", attributesMap,
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
                }, placeholders);
    }

    @Override
    public String getName() {
        return "RNRoktWidget";
    }

    protected void dispatchInAppropriateThread(Runnable runnable) {
        if (runnable == null) {
            return;
        }
        if (nativeModulesThread.getLooper().getThread().isAlive()) {
            reactContext.runOnNativeModulesQueueThread(runnable);
        }
    }
}






