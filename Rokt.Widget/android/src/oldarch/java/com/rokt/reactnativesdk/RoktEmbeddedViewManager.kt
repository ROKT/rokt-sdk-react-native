package com.rokt.reactnativesdk

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.rokt.roktsdk.RoktWidgetDimensionCallBack
import com.rokt.roktsdk.Widget

/**
 * Copyright 2024 Rokt Pte Ltd
 *
 * Licensed under the Rokt Software Development Kit (SDK) Terms of Use
 * Version 2.0 (the "License");
 *
 * You may not use this file except in compliance with the License.
 *
 * You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
 */
class RoktEmbeddedViewManager : ViewGroupManager<Widget>() {
    companion object {
        const val REACT_CLASS = "RoktNativeWidget"
    }
    override fun getName(): String = REACT_CLASS

    override fun createViewInstance(reactContext: ThemedReactContext): Widget {
        val widget = Widget(reactContext)
        setUpWidgetListeners(widget)
        return widget
    }

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
        return MapBuilder.builder<String, Any>()
            .put(
                "onWidgetHeightChanged",
                MapBuilder.of("registrationName", "onWidgetHeightChanged")
            )
            .put(
                "onWidgetMarginChanged",
                MapBuilder.of("registrationName", "onWidgetMarginChanged")
            )
            .build()
    }

    override fun needsCustomLayoutForChildren(): Boolean = false

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
