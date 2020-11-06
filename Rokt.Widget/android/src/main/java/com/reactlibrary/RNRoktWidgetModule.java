
package com.reactlibrary;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.rokt.roktsdk.Rokt;
import com.rokt.roktsdk.Widget;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.lang.ref.WeakReference;

public class RNRoktWidgetModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNRoktWidgetModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @ReactMethod
  public void initialize(String roktTagId, String appVersion){

    Activity currentActivity = getCurrentActivity();
    Rokt.INSTANCE.init(roktTagId, appVersion,currentActivity);

  }
  @ReactMethod
  public void execute(String viewName, ReadableMap attributes ,final Callback onLoad){

    Map<String,String> attributesMap = new HashMap(attributes.toHashMap());
    Map<String, WeakReference<Widget>> placeholders = new HashMap();

      for (Map.Entry<String, Object> entry : p.toHashMap().entrySet()) {
          String key = entry.getKey();
          Object value = entry.getValue();
          placeholders.put(key, new WeakReference(value));
      }


    Rokt.INSTANCE.execute(viewName, attributesMap,
            new Rokt.RoktCallback() {
              @Override
              public void onLoad() {
                  if(onLoad != null){
                      onLoad.invoke();
                  }
              }

              @Override
              public void onUnload(@NonNull Rokt.UnloadReasons unloadReasons) {
                  if (unloadReasons != null){

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
}