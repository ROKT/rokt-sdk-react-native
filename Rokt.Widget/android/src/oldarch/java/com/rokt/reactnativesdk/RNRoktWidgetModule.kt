package com.rokt.reactnativesdk

import com.facebook.react.bridge.*
import com.facebook.react.uimanager.NativeViewHierarchyManager
import com.facebook.react.uimanager.UIManagerModule
import com.rokt.reactnativesdk.RNRoktWidgetModuleImpl.Companion.MAX_LISTENERS
import com.rokt.roktsdk.CacheConfig
import com.rokt.roktsdk.FulfillmentAttributes
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.Rokt.RoktEventHandler
import com.rokt.roktsdk.Rokt.RoktEventType
import com.rokt.roktsdk.RoktConfig
import com.rokt.roktsdk.Widget
import kotlinx.coroutines.Job
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
        reactContext
    ) {
    private var roktEventHandler: RoktEventHandler? = null
    private var fulfillmentAttributesCallback: FulfillmentAttributes? = null
    private var debug = false

    private val eventSubscriptions = mutableMapOf<String, Job?>()
    private val listeners: MutableMap<Long, Rokt.RoktCallback> =
        object : LinkedHashMap<Long, Rokt.RoktCallback>() {
            override fun removeEldestEntry(eldest: Map.Entry<Long, Rokt.RoktCallback>): Boolean =
                this.size > MAX_LISTENERS
        }

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
        roktConfig: ReadableMap?
    ) {
        executeInternal(viewName, attributes, placeholders, roktConfig)
    }

    private fun executeInternal(
        viewName: String?,
        attributes: ReadableMap?,
        placeholders: ReadableMap?,
        roktConfig: ReadableMap? = null
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
                config = config
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
        roktConfig: ReadableMap?
    ) {
        execute2StepInternal(viewName, attributes, placeholders, roktConfig)
    }

    private fun execute2StepInternal(
        viewName: String?,
        attributes: ReadableMap?,
        placeholders: ReadableMap?,
        roktConfig: ReadableMap? = null
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
                roktEventCallback = object : Rokt.RoktEventCallback {
                    override fun onEvent(
                        eventType: RoktEventType,
                        roktEventHandler: RoktEventHandler
                    ) {
                        impl.setRoktEventHandler(roktEventHandler)
                        if (eventType == RoktEventType.FirstPositiveEngagement) {
                            impl.logDebug("onFirstPositiveEvent was fired")
                            impl.sendEvent(reactContext, "FirstPositiveResponse", null)
                        }
                    }
                },
                config = config
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

    override fun getName(): String {
        return impl.getName()
    }

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
        nativeViewHierarchyManager: NativeViewHierarchyManager
    ): Map<String, WeakReference<Widget>> {
        val placeholderMap: MutableMap<String, WeakReference<Widget>> = HashMap()

        if (placeholders != null) {
            placeholderMap.putAll(placeholders.toHashMap()
                .filterValues { value -> value is Double }
                .mapValues { pair -> (pair.value as Double).toInt() }
                .mapValues { pair -> nativeViewHierarchyManager.resolveView(pair.value) as? Widget }
                .filterValues { value -> value != null }
                .mapValues { WeakReference(it.value as Widget) })
        }
        return placeholderMap
    }

    private fun String.toColorMode(): RoktConfig.ColorMode {
        return when (this) {
            "dark" -> RoktConfig.ColorMode.DARK
            "light" -> RoktConfig.ColorMode.LIGHT
            else -> RoktConfig.ColorMode.SYSTEM
        }
    }

    private fun buildRoktConfig(
        roktConfig: ReadableMap?
    ): RoktConfig {
        val builder = RoktConfig.Builder()
        val configMap: Map<String, String> = impl.readableMapToMapOfStrings(roktConfig)
        configMap["colorMode"]?.let {
            builder.colorMode(it.toColorMode())
        }
        roktConfig?.getMap("cacheConfig")?.let {
            builder.cacheConfig(buildCacheConfig(it))
        }
        return builder.build()
    }

    private fun buildCacheConfig(cacheConfigMap: ReadableMap?): CacheConfig {
        val cacheDurationInSeconds =
            if (cacheConfigMap?.hasKey("cacheDurationInSeconds") == true) {
                cacheConfigMap.getDouble("cacheDurationInSeconds").toLong()
            } else {
                0L
            }
        val cacheAttributes = if (cacheConfigMap?.hasKey("cacheAttributes") == true) {
            cacheConfigMap.getMap("cacheAttributes")?.toHashMap()?.mapValues { it.value as String }
        } else {
            null
        }
        return CacheConfig(
            cacheDurationInSeconds = cacheDurationInSeconds,
            cacheAttributes = cacheAttributes
        )
    }
}