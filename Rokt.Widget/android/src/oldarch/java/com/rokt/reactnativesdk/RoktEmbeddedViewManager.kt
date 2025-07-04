package com.rokt.reactnativesdk

import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
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
    private val impl = RoktEmbeddedViewManagerImpl()

    override fun getName(): String = impl.getName()

    override fun createViewInstance(reactContext: ThemedReactContext): Widget = impl.createViewInstance(reactContext)

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? = MapBuilder
        .builder<String, Any>()
        .put(
            RoktEmbeddedViewManagerImpl.EVENT_HEIGHT_CHANGED,
            MapBuilder.of("registrationName", RoktEmbeddedViewManagerImpl.EVENT_HEIGHT_CHANGED),
        ).put(
            RoktEmbeddedViewManagerImpl.EVENT_MARGIN_CHANGED,
            MapBuilder.of("registrationName", RoktEmbeddedViewManagerImpl.EVENT_MARGIN_CHANGED),
        ).build()

    override fun needsCustomLayoutForChildren(): Boolean = false

    fun setPlaceholderName(view: Widget?, value: String?) {
        impl.setPlaceholderName(view, value)
    }
}
