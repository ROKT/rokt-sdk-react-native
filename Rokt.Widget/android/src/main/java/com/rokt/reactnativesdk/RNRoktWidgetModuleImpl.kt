package com.rokt.reactnativesdk

import android.app.Activity
import android.os.Handler
import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter
import com.rokt.roktsdk.CacheConfig
import com.rokt.roktsdk.FulfillmentAttributes
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.RoktConfig
import com.rokt.roktsdk.Rokt.Environment.Prod
import com.rokt.roktsdk.Rokt.RoktEventHandler
import com.rokt.roktsdk.Rokt.SdkFrameworkType.ReactNative
import com.rokt.roktsdk.RoktEvent
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch

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
class RNRoktWidgetModuleImpl(private val reactContext: ReactApplicationContext) {
    private var roktEventHandler: RoktEventHandler? = null
    private var fulfillmentAttributesCallback: FulfillmentAttributes? = null
    private var debug = false

    private val eventSubscriptions = mutableMapOf<String, Job?>()
    private val listeners: MutableMap<Long, Rokt.RoktCallback> =
        object : LinkedHashMap<Long, Rokt.RoktCallback>() {
            override fun removeEldestEntry(eldest: Map.Entry<Long, Rokt.RoktCallback>): Boolean =
                this.size > MAX_LISTENERS
        }

    fun getName(): String = REACT_CLASS

    fun initialize(roktTagId: String?, appVersion: String?, currentActivity: Activity?) {
        initRokt(roktTagId, appVersion, 4, currentActivity) { activity ->
            Rokt.init(
                roktTagId = requireNotNull(roktTagId),
                appVersion = requireNotNull(appVersion),
                activity = activity
            )
        }
    }

    fun initializeWithFontFiles(roktTagId: String?, appVersion: String?, fontsMap: ReadableMap?, currentActivity: Activity?) {
        initRokt(roktTagId, appVersion, 4, currentActivity) { activity ->
            Rokt.init(
                roktTagId = requireNotNull(roktTagId),
                appVersion = requireNotNull(appVersion),
                activity = activity,
                fontPostScriptNames = HashSet(),
                fontFilePathMap = readableMapToMapOfStrings(fontsMap)
            )
        }
    }

    fun setFulfillmentAttributes(attributes: ReadableMap?) {
        if (roktEventHandler != null) {
            val fulfillmentAttributes = readableMapToMapOfStrings(attributes)
            roktEventHandler?.setFulfillmentAttributes(fulfillmentAttributes)
            logDebug("Calling setFulfillmentAttributes")
        } else {
            logDebug("RoktEventHandler is null, make sure you run execute2Step before calling setFulfillmentAttributes")
        }

        if (fulfillmentAttributesCallback != null) {
            val fulfillmentAttributes = readableMapToMapOfStrings(attributes)
            fulfillmentAttributesCallback?.sendAttributes(fulfillmentAttributes)
            logDebug("Calling setFulfillmentAttributes")
        }
    }

    fun purchaseFinalized(placementId: String, catalogItemId: String, success: Boolean) {
        Rokt.purchaseFinalized(placementId, catalogItemId, success)
    }

    fun setEnvironmentToStage() {
        Rokt.setEnvironment(Rokt.Environment.Stage)
    }

    fun setEnvironmentToProd() {
        Rokt.setEnvironment(Prod)
    }

    fun setLoggingEnabled(enabled: Boolean) {
        this.debug = enabled
        Rokt.setLoggingEnabled(enabled)
    }

    fun setRoktEventHandler(roktEventHandler: RoktEventHandler) {
        this.roktEventHandler = roktEventHandler
    }

    fun createRoktCallback(): Rokt.RoktCallback {
        val callback: Rokt.RoktCallback = object : Rokt.RoktCallback {
            override fun onLoad() {
                sendCallback("onLoad", null)
            }

            override fun onUnload(reason: Rokt.UnloadReasons) {
                sendCallback("onUnLoad", reason.toString())
            }

            override fun onShouldShowLoadingIndicator() {
                sendCallback("onShouldShowLoadingIndicator", null)
            }

            override fun onShouldHideLoadingIndicator() {
                sendCallback("onShouldHideLoadingIndicator", null)
            }
        }
        listeners[System.currentTimeMillis()] = callback
        return callback
    }

    fun sendCallback(eventValue: String, reason: String?) {
        val params = Arguments.createMap()
        params.putString("callbackValue", eventValue)
        if (reason != null) {
            params.putString("reason", reason)
        }
        sendEvent(reactContext, "RoktCallback", params)
    }

    fun sendEvent(
        reactContext: ReactContext?,
        eventName: String,
        params: WritableMap?
    ) {
        reactContext?.getJSModule(RCTDeviceEventEmitter::class.java)?.emit(eventName, params)
    }

    fun readableMapToMapOfStrings(attributes: ReadableMap?): Map<String, String> =
        attributes?.toHashMap()?.filter { it.value is String }?.mapValues { it.value as String }
            ?: emptyMap()

    fun logDebug(message: String) {
        if (debug) {
            Log.d("Rokt", message)
        }
    }

    fun String.toColorMode(): RoktConfig.ColorMode {
        return when (this) {
            "dark" -> RoktConfig.ColorMode.DARK
            "light" -> RoktConfig.ColorMode.LIGHT
            else -> RoktConfig.ColorMode.SYSTEM
        }
    }

    fun buildRoktConfig(roktConfig: ReadableMap?): RoktConfig {
        val builder = RoktConfig.Builder()
        val configMap: Map<String, String> = readableMapToMapOfStrings(roktConfig)
        configMap["colorMode"]?.let {
            builder.colorMode(it.toColorMode())
        }
        roktConfig?.getMap("cacheConfig")?.let {
            builder.cacheConfig(buildCacheConfig(it))
        }
        return builder.build()
    }

    fun buildCacheConfig(cacheConfigMap: ReadableMap?): CacheConfig {
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

    fun startRoktEventListener(flow: Flow<RoktEvent>, currentActivity: Activity?, viewName: String? = null) {
        val activeJob = eventSubscriptions[viewName.orEmpty()]?.takeIf { it.isActive }
        if (activeJob != null) {
            return
        }
        val job = (currentActivity as? LifecycleOwner)?.lifecycleScope?.launch {
            (currentActivity as LifecycleOwner).repeatOnLifecycle(Lifecycle.State.CREATED) {
                flow.collect { event ->
                    val params = Arguments.createMap()
                    var eventName = ""
                    val placementId: String? = when (event) {
                        is RoktEvent.FirstPositiveEngagement -> {
                            eventName = "FirstPositiveEngagement"
                            fulfillmentAttributesCallback = event.fulfillmentAttributes
                            event.id
                        }

                        RoktEvent.HideLoadingIndicator -> {
                            eventName = "HideLoadingIndicator"
                            null
                        }

                        is RoktEvent.OfferEngagement -> {
                            eventName = "OfferEngagement"
                            event.id
                        }

                        is RoktEvent.PlacementClosed -> {
                            eventName = "PlacementClosed"
                            event.id
                        }

                        is RoktEvent.PlacementCompleted -> {
                            eventName = "PlacementCompleted"
                            event.id
                        }

                        is RoktEvent.PlacementFailure -> {
                            eventName = "PlacementFailure"
                            event.id
                        }

                        is RoktEvent.PlacementInteractive -> {
                            eventName = "PlacementInteractive"
                            event.id
                        }

                        is RoktEvent.PlacementReady -> {
                            eventName = "PlacementReady"
                            event.id
                        }

                        is RoktEvent.PositiveEngagement -> {
                            eventName = "PositiveEngagement"
                            event.id
                        }

                        RoktEvent.ShowLoadingIndicator -> {
                            eventName = "ShowLoadingIndicator"
                            null
                        }

                        is RoktEvent.InitComplete -> {
                            eventName = "InitComplete"
                            params.putString("status", event.success.toString())
                            null
                        }

                        is RoktEvent.OpenUrl -> {
                            eventName = "OpenUrl"
                            params.putString("url", event.url)
                            event.id
                        }

                        is RoktEvent.CartItemInstantPurchase -> {
                            eventName = "CartItemInstantPurchase"
                            params.putString("cartItemId", event.cartItemId)
                            params.putString("catalogItemId", event.catalogItemId)
                            params.putString("currency", event.currency)
                            params.putString("description", event.description)
                            params.putString("linkedProductId", event.linkedProductId)
                            params.putDouble("totalPrice", event.totalPrice)
                            params.putInt("quantity", event.quantity)
                            params.putDouble("unitPrice", event.unitPrice)
                            event.placementId
                        }

                        else -> {
                            eventName = "Unknown"
                            null
                        }
                    }

                    placementId?.let { params.putString("placementId", it) }
                    params.putString("event", eventName)
                    viewName?.let { params.putString("viewName", it) }
                    sendEvent(reactContext, "RoktEvents", params)
                }
            }
        }
        eventSubscriptions[viewName.orEmpty()] = job
    }

    private fun initRokt(
        roktTagId: String?,
        appVersion: String?,
        retryCount: Int,
        currentActivity: Activity?,
        init: (activity: Activity) -> Unit
    ) {
        if (roktTagId == null || appVersion == null) {
            logDebug("roktTagId and appVersion cannot be null")
            return
        }
        Rokt.setFrameworkType(ReactNative)
        eventSubscriptions.clear()
        startRoktEventListener(Rokt.globalEvents(), currentActivity)
        if (currentActivity == null) {
            // When the init was called from ReactComponent init and the activity is not fully resumed,
            // the currentActivity could be null.
            // Add a delay in this scenario and call the init.
            // Recursive call initRokt to retry until retryCount becomes 0
            Handler(reactContext.mainLooper).postDelayed({
                currentActivity?.let(init) ?: run {
                    if (retryCount == 0) {
                        logDebug("Failed to initialize Rokt. Activity is null!!")
                    } else {
                        initRokt(roktTagId, appVersion, retryCount - 1, reactContext.currentActivity, init)
                    }
                }
            }, 100)
        } else {
            currentActivity.let(init)
        }
    }

    companion object {
        const val MAX_LISTENERS = 5
        const val REACT_CLASS = "RNRoktWidget"
    }
}
