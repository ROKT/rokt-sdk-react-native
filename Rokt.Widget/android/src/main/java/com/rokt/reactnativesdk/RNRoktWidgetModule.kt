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
import com.facebook.react.uimanager.NativeViewHierarchyManager
import com.facebook.react.uimanager.UIManagerModule
import com.rokt.roktsdk.FulfillmentAttributes
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.Rokt.Environment.Prod
import com.rokt.roktsdk.Rokt.RoktEventHandler
import com.rokt.roktsdk.Rokt.RoktEventType
import com.rokt.roktsdk.Rokt.SdkFrameworkType.ReactNative
import com.rokt.roktsdk.RoktEvent
import com.rokt.roktsdk.Widget
import kotlinx.coroutines.launch
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

    private val listeners: MutableMap<Long, Rokt.RoktCallback> = object : LinkedHashMap<Long, Rokt.RoktCallback>() {
        override fun removeEldestEntry(eldest: Map.Entry<Long, Rokt.RoktCallback>): Boolean = this.size > MAX_LISTENERS
    }

    @ReactMethod
    fun initialize(roktTagId: String?, appVersion: String?) {
        initRokt(roktTagId, appVersion) { activity ->
            Rokt.init(requireNotNull(roktTagId), requireNotNull(appVersion), activity)
        }
    }

    @ReactMethod
    fun initializeWithFontFiles(roktTagId: String?, appVersion: String?, fontsMap: ReadableMap?) {
        initRokt(roktTagId, appVersion) { activity ->
            Rokt.init(requireNotNull(roktTagId), requireNotNull(appVersion), activity, HashSet(), readableMapToMapOfStrings(fontsMap))
        }
    }

    @ReactMethod
    fun execute(viewName: String?, attributes: ReadableMap?, placeholders: ReadableMap?) {
        if (viewName == null) {
            logDebug("Execute failed. ViewName cannot be null")
            return
        }

        val uiManager = reactContext.getNativeModule(UIManagerModule::class.java)
        startRoktEventListener(viewName)
        uiManager?.addUIBlock { nativeViewHierarchyManager ->
            Rokt.execute(
                viewName,
                readableMapToMapOfStrings(attributes),
                createRoktCallback(),
                safeUnwrapPlaceholders(placeholders, nativeViewHierarchyManager)
            )
        }
    }

    @ReactMethod
    fun execute2Step(viewName: String?, attributes: ReadableMap?, placeholders: ReadableMap?) {
        if (viewName == null) {
            logDebug("Execute failed. ViewName cannot be null")
            return
        }

        val uiManager = reactContext.getNativeModule(UIManagerModule::class.java)
        startRoktEventListener(viewName)
        uiManager?.addUIBlock { nativeViewHierarchyManager ->
            Rokt.execute2Step(
                viewName,
                readableMapToMapOfStrings(attributes),
                createRoktCallback(),
                safeUnwrapPlaceholders(placeholders, nativeViewHierarchyManager),
                object : Rokt.RoktEventCallback {
                    override fun onEvent(eventType: RoktEventType, roktEventHandler: RoktEventHandler) {
                        setRoktEventHandler(roktEventHandler)
                        if (eventType == RoktEventType.FirstPositiveEngagement) {
                            logDebug("onFirstPositiveEvent was fired")
                            sendEvent(reactContext, "FirstPositiveResponse", null)
                        }
                    }
                }
            )
        }
    }

    private fun initRokt(roktTagId: String?, appVersion: String?, init: (activity: Activity) -> Unit) {
        if (roktTagId == null || appVersion == null) {
            logDebug("roktTagId and appVersion cannot be null")
            return
        }
        Rokt.setFrameworkType(ReactNative)
        if (currentActivity == null) {
            // When the init was called from ReactComponent init and the activity is not fully resumed,
            // the currentActivity could be null.
            // Add a delay in this scenario and call the init
            Handler(reactContext.mainLooper).postDelayed({
                currentActivity?.let(init) ?: logDebug("Failed to initialize Rokt. Activity is null!!")
            }, 500)
        } else {
            currentActivity?.let(init)
        }
    }

    private fun sendEvent(
        reactContext: ReactContext?,
        eventName: String,
        params: WritableMap?
    ) {
        reactContext?.getJSModule(RCTDeviceEventEmitter::class.java)?.emit(eventName, params)
    }

    @ReactMethod
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

    private fun setRoktEventHandler(roktEventHandler: RoktEventHandler) {
        this.roktEventHandler = roktEventHandler
    }

    override fun getName(): String {
        return "RNRoktWidget"
    }

    @ReactMethod
    fun setEnvironmentToStage() {
        Rokt.setEnvironment(Rokt.Environment.Stage)
    }

    @ReactMethod
    fun setEnvironmentToProd() {
        Rokt.setEnvironment(Prod)
    }

    @ReactMethod
    fun setLoggingEnabled(enabled: Boolean) {
        this.debug = enabled
        Rokt.setLoggingEnabled(enabled)
    }

    private fun logDebug(message: String) {
        if (debug) {
            Log.d("Rokt", message)
        }
    }

    private fun readableMapToMapOfStrings(attributes: ReadableMap?): Map<String, String> =
        attributes?.toHashMap()?.filter { it.value is String }?.mapValues { it.value as String } ?: emptyMap()


    private fun createRoktCallback(): Rokt.RoktCallback {
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

    private fun sendCallback(eventValue: String, reason: String?) {
        val params = Arguments.createMap()
        params.putString("callbackValue", eventValue)
        if (reason != null) {
            params.putString("reason", reason)
        }
        sendEvent(reactContext, "RoktCallback", params)
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

    private fun startRoktEventListener(viewName: String) {
        (currentActivity as? LifecycleOwner)?.lifecycleScope?.launch {
            (currentActivity as LifecycleOwner).repeatOnLifecycle(Lifecycle.State.CREATED) {
                Rokt.events(viewName).collect { event ->
                    val params = Arguments.createMap()
                    var eventName: String = ""
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
                    }

                    placementId?.let { params.putString("placementId", it) }
                    params.putString("event", eventName)
                    params.putString("viewName", viewName)
                    sendEvent(reactContext, "RoktEvents", params)
                }
            }
        }
    }
}

private const val MAX_LISTENERS = 5
