package com.rokt.reactnativesdk

import com.facebook.react.bridge.*
import com.facebook.react.uimanager.NativeViewHierarchyManager
import com.facebook.react.uimanager.UIManagerModule
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.Rokt.RoktEventHandler
import com.rokt.roktsdk.Rokt.RoktEventType
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
        impl.initialize(roktTagId, appVersion, currentActivity)
    }

    @ReactMethod
    fun initializeWithFontFiles(roktTagId: String?, appVersion: String?, fontsMap: ReadableMap?) {
        impl.initializeWithFontFiles(roktTagId, appVersion, fontsMap, currentActivity)
    }

    @ReactMethod
    fun execute(viewName: String?, attributes: ReadableMap?, placeholders: ReadableMap?) {
        executeInternal(viewName, attributes, placeholders)
    }

    @ReactMethod
    fun executeWithConfig(
        viewName: String?,
        attributes: ReadableMap?,
        placeholders: ReadableMap?,
        roktConfig: ReadableMap?,
    ) {
        executeInternal(viewName, attributes, placeholders, roktConfig)
    }

    private fun executeInternal(
        viewName: String?,
        attributes: ReadableMap?,
        placeholders: ReadableMap?,
        roktConfig: ReadableMap? = null,
    ) {
        if (viewName == null) {
            impl.logDebug("Execute failed. ViewName cannot be null")
            return
        }

        val uiManager = reactContext.getNativeModule(UIManagerModule::class.java)
        impl.startRoktEventListener(Rokt.events(viewName), currentActivity, viewName)

        val config = roktConfig?.let { impl.buildRoktConfig(it) }
        uiManager?.addUIBlock { nativeViewHierarchyManager ->
            Rokt.execute(
                viewName = viewName,
                attributes = impl.readableMapToMapOfStrings(attributes),
                callback = impl.createRoktCallback(),
                placeholders = safeUnwrapPlaceholders(placeholders, nativeViewHierarchyManager),
                config = config,
            )
        }
    }

    @ReactMethod
    fun execute2Step(viewName: String?, attributes: ReadableMap?, placeholders: ReadableMap?) {
        execute2StepInternal(viewName, attributes, placeholders)
    }

    @ReactMethod
    fun execute2StepWithConfig(
        viewName: String?,
        attributes: ReadableMap?,
        placeholders: ReadableMap?,
        roktConfig: ReadableMap?,
    ) {
        execute2StepInternal(viewName, attributes, placeholders, roktConfig)
    }

    private fun execute2StepInternal(
        viewName: String?,
        attributes: ReadableMap?,
        placeholders: ReadableMap?,
        roktConfig: ReadableMap? = null,
    ) {
        if (viewName == null) {
            impl.logDebug("Execute failed. ViewName cannot be null")
            return
        }

        val uiManager = reactContext.getNativeModule(UIManagerModule::class.java)
        impl.startRoktEventListener(Rokt.events(viewName), currentActivity, viewName)
        val config = roktConfig?.let { impl.buildRoktConfig(it) }
        uiManager?.addUIBlock { nativeViewHierarchyManager ->
            Rokt.execute2Step(
                viewName = viewName,
                attributes = impl.readableMapToMapOfStrings(attributes),
                callback = impl.createRoktCallback(),
                placeholders = safeUnwrapPlaceholders(placeholders, nativeViewHierarchyManager),
                roktEventCallback =
                object : Rokt.RoktEventCallback {
                    override fun onEvent(eventType: RoktEventType, roktEventHandler: RoktEventHandler) {
                        impl.setRoktEventHandler(roktEventHandler)
                        if (eventType == RoktEventType.FirstPositiveEngagement) {
                            impl.logDebug("onFirstPositiveEvent was fired")
                            impl.sendEvent(reactContext, "FirstPositiveResponse", null)
                        }
                    }
                },
                config = config,
            )
        }
    }

    @ReactMethod
    fun setFulfillmentAttributes(attributes: ReadableMap?) {
        impl.setFulfillmentAttributes(attributes)
    }

    @ReactMethod
    fun purchaseFinalized(placementId: String, catalogItemId: String, success: Boolean) {
        impl.purchaseFinalized(placementId, catalogItemId, success)
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

    @ReactMethod
    fun setLoggingEnabled(enabled: Boolean) {
        impl.setLoggingEnabled(enabled)
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
