package com.rokt.reactnativesdk

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.events.Event
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

        // JS-facing registration names (the props declared in RoktNativeWidgetNativeComponent.ts).
        const val EVENT_HEIGHT_CHANGED = "onWidgetHeightChanged"
        const val EVENT_MARGIN_CHANGED = "onWidgetMarginChanged"

        // Native event names dispatched through the EventDispatcher. React Native maps the
        // "top"-prefixed native name back to the "on"-prefixed JS prop on both the old (Paper)
        // and new (Fabric) architectures.
        const val EVENT_HEIGHT_CHANGED_NATIVE = "topWidgetHeightChanged"
        const val EVENT_MARGIN_CHANGED_NATIVE = "topWidgetMarginChanged"
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

    /**
     * Dispatches the embedded widget height change to JS.
     *
     * Uses [UIManagerHelper.getEventDispatcherForReactTag] / [EventDispatcher] which is the
     * supported path on both the legacy (Paper) renderer and the New Architecture (Fabric /
     * Bridgeless). The previous implementation used `getJSModule(RCTEventEmitter)` which throws an
     * `IllegalArgumentException` under the New Architecture (RN 0.83+) — the height never reached JS
     * and embedded placements stayed at height 0 (never rendered).
     */
    fun changeHeight(context: ReactContext, height: Int, id: Int) {
        val surfaceId = UIManagerHelper.getSurfaceId(context)
        UIManagerHelper.getEventDispatcherForReactTag(context, id)
            ?.dispatchEvent(WidgetHeightChangedEvent(surfaceId, id, height))
    }

    fun changeMargin(context: ReactContext, id: Int, start: Int, top: Int, end: Int, bottom: Int) {
        val surfaceId = UIManagerHelper.getSurfaceId(context)
        UIManagerHelper.getEventDispatcherForReactTag(context, id)
            ?.dispatchEvent(WidgetMarginChangedEvent(surfaceId, id, start, top, end, bottom))
    }
}

/**
 * Direct event carrying the measured widget height (in dp) back to the JS `onWidgetHeightChanged`
 * handler. Compatible with both the old and new React Native architectures.
 */
internal class WidgetHeightChangedEvent(surfaceId: Int, viewId: Int, private val height: Int) :
    Event<WidgetHeightChangedEvent>(surfaceId, viewId) {
    override fun getEventName(): String = RoktEmbeddedViewManagerImpl.EVENT_HEIGHT_CHANGED_NATIVE

    override fun getEventData(): WritableMap = Arguments.createMap().apply {
        putString("height", height.toString())
    }
}

/**
 * Direct event carrying the measured widget margins (in dp) back to the JS `onWidgetMarginChanged`
 * handler. Compatible with both the old and new React Native architectures.
 */
internal class WidgetMarginChangedEvent(
    surfaceId: Int,
    viewId: Int,
    private val start: Int,
    private val top: Int,
    private val end: Int,
    private val bottom: Int,
) : Event<WidgetMarginChangedEvent>(surfaceId, viewId) {
    override fun getEventName(): String = RoktEmbeddedViewManagerImpl.EVENT_MARGIN_CHANGED_NATIVE

    override fun getEventData(): WritableMap = Arguments.createMap().apply {
        putString("marginLeft", start.toString())
        putString("marginTop", top.toString())
        putString("marginRight", end.toString())
        putString("marginBottom", bottom.toString())
    }
}
