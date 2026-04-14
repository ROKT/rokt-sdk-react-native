package com.rokt.reactnativesdk

import com.facebook.react.bridge.*
import com.facebook.react.uimanager.NativeViewHierarchyManager
import com.facebook.react.uimanager.UIManagerModule
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.Widget
import java.lang.ref.WeakReference

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
class RNRoktWidgetModule internal constructor(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(
        reactContext,
    ) {
    private val impl = RNRoktWidgetModuleImpl(reactContext)

    @ReactMethod
    fun initialize(roktTagId: String?, appVersion: String?) {
        impl.initialize(roktTagId, appVersion, reactContext.currentActivity)
    }

    @ReactMethod
    fun initializeWithFontFiles(roktTagId: String?, appVersion: String?, fontsMap: ReadableMap?) {
        impl.initializeWithFontFiles(roktTagId, appVersion, fontsMap, reactContext.currentActivity)
    }

    @ReactMethod
    fun selectPlacements(identifier: String?, attributes: ReadableMap?, placeholders: ReadableMap?) {
        executeInternal(identifier, attributes, placeholders)
    }

    @ReactMethod
    fun selectPlacementsWithConfig(
        identifier: String?,
        attributes: ReadableMap?,
        placeholders: ReadableMap?,
        roktConfig: ReadableMap?,
    ) {
        executeInternal(identifier, attributes, placeholders, roktConfig)
    }

    private fun executeInternal(
        identifier: String?,
        attributes: ReadableMap?,
        placeholders: ReadableMap?,
        roktConfig: ReadableMap? = null,
    ) {
        if (identifier == null) {
            impl.logDebug("Execute failed. Identifier cannot be null")
            return
        }

        val uiManager = reactContext.getNativeModule(UIManagerModule::class.java)
        impl.startRoktEventListener(Rokt.events(identifier), reactContext.currentActivity, identifier)

        val config = roktConfig?.let { impl.buildRoktConfig(it) }
        uiManager?.addUIBlock { nativeViewHierarchyManager ->
            Rokt.selectPlacements(
                identifier = identifier,
                attributes = impl.readableMapToMapOfStrings(attributes),
                placeholders = safeUnwrapPlaceholders(placeholders, nativeViewHierarchyManager),
                config = config,
            )
        }
    }

    @ReactMethod
    fun selectShoppableAds(identifier: String?, attributes: ReadableMap?) {
        selectShoppableAdsInternal(identifier, attributes)
    }

    @ReactMethod
    fun selectShoppableAdsWithConfig(
        identifier: String?,
        attributes: ReadableMap?,
        roktConfig: ReadableMap?,
    ) {
        selectShoppableAdsInternal(identifier, attributes, roktConfig)
    }

    private fun selectShoppableAdsInternal(
        identifier: String?,
        attributes: ReadableMap?,
        roktConfig: ReadableMap? = null,
    ) {
        if (identifier == null) {
            impl.logDebug("selectShoppableAds failed. Identifier cannot be null")
            return
        }
        impl.startRoktEventListener(Rokt.events(identifier), reactContext.currentActivity, identifier)
        val config = roktConfig?.let { impl.buildRoktConfig(it) }
        // No placeholders needed for shoppable ads (full-screen overlay)
        Rokt.selectShoppableAds(
            identifier = identifier,
            attributes = impl.readableMapToMapOfStrings(attributes),
            config = config,
        )
    }

    @ReactMethod
    fun purchaseFinalized(identifier: String, catalogItemId: String, success: Boolean) {
        impl.purchaseFinalized(identifier, catalogItemId, success)
    }

    override fun getName(): String = impl.getName()

    @ReactMethod
    fun setEnvironmentToStage() {
        impl.setEnvironmentToStage()
    }

    @ReactMethod
    fun setEnvironmentToProd() {
        impl.setEnvironmentToProd()
    }

    private fun safeUnwrapPlaceholders(
        placeholders: ReadableMap?,
        nativeViewHierarchyManager: NativeViewHierarchyManager,
    ): Map<String, WeakReference<Widget>> {
        val placeholderMap: MutableMap<String, WeakReference<Widget>> = HashMap()

        if (placeholders != null) {
            placeholderMap.putAll(
                placeholders
                    .toHashMap()
                    .filterValues { value -> value is Double }
                    .mapValues { pair -> (pair.value as Double).toInt() }
                    .mapValues { pair -> nativeViewHierarchyManager.resolveView(pair.value) as? Widget }
                    .filterValues { value -> value != null }
                    .mapValues { WeakReference(it.value as Widget) },
            )
        }
        return placeholderMap
    }
}
