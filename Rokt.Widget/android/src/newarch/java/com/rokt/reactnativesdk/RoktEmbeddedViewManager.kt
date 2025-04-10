package com.rokt.reactnativesdk

import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.RoktNativeWidgetManagerInterface
import com.rokt.roktsdk.Widget

// @ReactModule annotation may be unnecessary if registration is handled by codegen/package
// but keeping it commented in case it's needed
// @ReactModule(name = RoktEmbeddedViewManagerImpl.REACT_CLASS)
class RoktEmbeddedViewManager : SimpleViewManager<Widget>(), RoktNativeWidgetManagerInterface<Widget> {

    private val impl = RoktEmbeddedViewManagerImpl()

    override fun getName(): String = impl.getName()

    override fun createViewInstance(reactContext: ThemedReactContext): Widget {
        return impl.createViewInstance(reactContext)
    }

    @ReactProp(name = "placeholderName")
    override fun setPlaceholderName(view: Widget?, value: String?) {
        impl.setPlaceholderName(view, value)
    }
}