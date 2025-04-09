package com.rokt.reactnativesdk

import android.widget.TextView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facebook.react.viewmanagers.RoktNativeWidgetManagerInterface
import com.rokt.roktsdk.RoktWidgetDimensionCallBack
import com.rokt.roktsdk.Widget

@ReactModule(name = RoktEmbeddedViewManager.REACT_CLASS)
class RoktEmbeddedViewManager : SimpleViewManager<Widget>(), RoktNativeWidgetManagerInterface<Widget> {
    companion object {
        const val REACT_CLASS = "RoktNativeWidget"
    }
    override fun getName(): String = REACT_CLASS

    override fun createViewInstance(reactContext: ThemedReactContext): Widget {
        val widget = Widget(reactContext)
        setUpWidgetListeners(widget)
        return widget
    }

    @ReactProp(name = "placeholderName")
    override fun setPlaceholderName(view: Widget?, value: String?) {
        view?.tag = value
    }

    private fun setUpWidgetListeners(widget: Widget) {
        widget.registerDimensionListener(object : RoktWidgetDimensionCallBack {
            override fun onHeightChanged(height: Int) {
                changeHeight(widget.context as ReactContext, height, widget.id)
            }

            override fun onMarginChanged(start: Int, top: Int, end: Int, bottom: Int) {
                changeMargin(widget.context as ReactContext, widget.id, start, top, end, bottom)
            }
        })
    }

    fun changeHeight(context: ReactContext, height: Int, id: Int) {
        val event = Arguments.createMap()
        event.putString("height", height.toString())
        context.getJSModule(RCTEventEmitter::class.java)
            .receiveEvent(id, "onWidgetHeightChanged", event)
    }

    fun changeMargin(context: ReactContext, id: Int, start: Int, top: Int, end: Int, bottom: Int) {
        val event = Arguments.createMap()
        event.putString("marginLeft", start.toString())
        event.putString("marginTop", top.toString())
        event.putString("marginRight", end.toString())
        event.putString("marginBottom", bottom.toString())
        context.getJSModule(RCTEventEmitter::class.java)
            .receiveEvent(id, "onWidgetMarginChanged", event)
    }
}