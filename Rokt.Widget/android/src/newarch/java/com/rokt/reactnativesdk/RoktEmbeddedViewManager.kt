package com.rokt.reactnativesdk

import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.RoktNativeWidgetManagerDelegate
import com.facebook.react.viewmanagers.RoktNativeWidgetManagerInterface
import com.rokt.roktsdk.Widget

class RoktEmbeddedViewManager :
    SimpleViewManager<Widget>(),
    RoktNativeWidgetManagerInterface<Widget> {
    private val impl = RoktEmbeddedViewManagerImpl()

    // Fabric routes props through the codegen-generated delegate; without this override the
    // base ViewManager logs "ViewManager using codegen must override getDelegate method".
    private val delegate = RoktNativeWidgetManagerDelegate<Widget, RoktEmbeddedViewManager>(this)

    override fun getDelegate(): ViewManagerDelegate<Widget> = delegate

    override fun getName(): String = impl.getName()

    override fun createViewInstance(reactContext: ThemedReactContext): Widget = impl.createViewInstance(reactContext)

    override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> = mutableMapOf(
        RoktEmbeddedViewManagerImpl.EVENT_HEIGHT_CHANGED_NATIVE to
            mapOf("registrationName" to RoktEmbeddedViewManagerImpl.EVENT_HEIGHT_CHANGED),
        RoktEmbeddedViewManagerImpl.EVENT_MARGIN_CHANGED_NATIVE to
            mapOf("registrationName" to RoktEmbeddedViewManagerImpl.EVENT_MARGIN_CHANGED),
    )

    override fun setPlaceholderName(view: Widget?, value: String?) {
        impl.setPlaceholderName(view, value)
    }
}
