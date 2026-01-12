package com.rokt.reactnativesdk

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.ThemedReactContext
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
class RoktEmbeddedViewManagerImpl {
    companion object {
        const val REACT_CLASS = "RoktNativeWidget"
        const val EVENT_HEIGHT_CHANGED = "onWidgetHeightChanged"
        const val EVENT_MARGIN_CHANGED = "onWidgetMarginChanged"
    }

    fun getName(): String = REACT_CLASS

    fun createViewInstance(reactContext: ThemedReactContext): Widget {
        val widget = Widget(reactContext)
        setUpWidgetListeners(widget)
        return widget
    }

    fun setPlaceholderName(view: Widget?, value: String?) {
        view?.tag = value
    }

    private fun setUpWidgetListeners(widget: Widget) {
        widget.registerDimensionListener(
            object : RoktWidgetDimensionCallBack {
                override fun onHeightChanged(height: Int) {
                    changeHeight(widget.context as ReactContext, height, widget.id)
                }
            },
        )
    }

    fun changeHeight(context: ReactContext, height: Int, id: Int) {
        val event = Arguments.createMap()
        event.putString("height", height.toString())
        context
            .getJSModule(RCTEventEmitter::class.java)
            .receiveEvent(id, EVENT_HEIGHT_CHANGED, event)
    }

    fun changeMargin(context: ReactContext, id: Int, start: Int, top: Int, end: Int, bottom: Int) {
        val event = Arguments.createMap()
        event.putString("marginLeft", start.toString())
        event.putString("marginTop", top.toString())
        event.putString("marginRight", end.toString())
        event.putString("marginBottom", bottom.toString())
        context
            .getJSModule(RCTEventEmitter::class.java)
            .receiveEvent(id, EVENT_MARGIN_CHANGED, event)
    }
}
