package com.rokt.reactnativesdk

import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.RoktNativeWidgetManagerInterface
import com.rokt.roktsdk.Widget

class RoktEmbeddedViewManager :
    SimpleViewManager<Widget>(),
    RoktNativeWidgetManagerInterface<Widget> {
    private val impl = RoktEmbeddedViewManagerImpl()

    override fun getName(): String = impl.getName()

    override fun createViewInstance(reactContext: ThemedReactContext): Widget = impl.createViewInstance(reactContext)

    override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> = mutableMapOf(
        RoktEmbeddedViewManagerImpl.EVENT_HEIGHT_CHANGED_NATIVE to
            mapOf("registrationName" to RoktEmbeddedViewManagerImpl.EVENT_HEIGHT_CHANGED),
        RoktEmbeddedViewManagerImpl.EVENT_MARGIN_CHANGED_NATIVE to
            mapOf("registrationName" to RoktEmbeddedViewManagerImpl.EVENT_MARGIN_CHANGED),
    )

    @ReactProp(name = "placeholderName")
    override fun setPlaceholderName(view: Widget?, value: String?) {
        impl.setPlaceholderName(view, value)
    }
}
