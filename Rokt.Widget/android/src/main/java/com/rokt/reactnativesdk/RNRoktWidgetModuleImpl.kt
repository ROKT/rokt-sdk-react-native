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
import com.facebook.react.uimanager.UIManagerHelper
import com.rokt.roktsdk.CacheConfig
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.Rokt.Environment.Prod
import com.rokt.roktsdk.Rokt.SdkFrameworkType.ReactNative
import com.rokt.roktsdk.RoktConfig
import com.rokt.roktsdk.RoktEvent
import com.rokt.roktsdk.Widget
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import java.lang.ref.WeakReference
import java.net.MalformedURLException
import java.net.URL
import java.util.UUID

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
    private var debug = false

    @Volatile private var invalidated = false
    private val waitPrefix = UUID.randomUUID().toString()
    private val waitKeys = mutableSetOf<String>()

    fun selectPlacements(
        identifier: String?,
        attributes: ReadableMap?,
        placeholders: ReadableMap?,
        roktConfig: ReadableMap?,
    ) {
        if (identifier == null) {
            logDebug("Select placements failed. Identifier cannot be null")
            return
        }
        val values = placeholders?.toHashMap().orEmpty()
        val nativeAttributes = readableMapToMapOfStrings(attributes)
        val config = roktConfig?.let { buildRoktConfig(it) }
        UiThreadUtil.runOnUiThread {
            whenPlaceholdersMounted(identifier, values) {
                startRoktEventListener(Rokt.events(identifier), reactContext.currentActivity, identifier)
                Rokt.selectPlacements(
                    identifier = identifier,
                    attributes = nativeAttributes,
                    placeholders = resolvePlaceholders(values),
                    config = config,
                )
            }
        }
    }

    // UI thread only. The callback is always deferred beyond the native mount transaction.
    internal fun whenPlaceholdersMounted(identifier: String, placeholders: Map<String, Any?>, onReady: () -> Unit) {
        if (invalidated) return
        val names = placeholders.filterValues { it !is Number || it.toDouble() <= 0 }.keys
        val key = "$waitPrefix:$identifier"
        waitKeys.add(key)
        RoktPlaceholderRegistry.awaitNames(key, names, 2000, onDiscard = {
            logDebug("Pending selectPlacements dropped for: $identifier")
        }) {
            waitKeys.remove(key)
            if (!invalidated) onReady()
        }
    }

    internal fun resolvePlaceholders(placeholders: Map<String, Any?>): Map<String, WeakReference<Widget>> {
        val resolved = mutableMapOf<String, WeakReference<Widget>>()
        for ((name, value) in placeholders) {
            var widget: Widget? = null
            if (value is Number && value.toDouble() > 0) {
                try {
                    val tag = value.toInt()
                    widget = UIManagerHelper.getUIManagerForReactTag(reactContext, tag)?.resolveView(tag) as? Widget
                } catch (e: RuntimeException) {
                    logDebug("Cannot resolve React tag $value: ${e.message}")
                }
            }
            widget = widget ?: RoktPlaceholderRegistry.lookup(name) as? Widget
            if (widget != null) {
                resolved[name] = WeakReference(widget)
            } else {
                Log.w("Rokt", "Cannot resolve placeholder $name (reactTag $value)")
            }
        }
        return resolved
    }

    fun invalidate() {
        invalidated = true
        UiThreadUtil.runOnUiThread {
            for (key in waitKeys) RoktPlaceholderRegistry.cancelWait(key)
            waitKeys.clear()
            for (job in eventSubscriptions.values) job?.cancel()
            eventSubscriptions.clear()
        }
    }

    private val eventSubscriptions = mutableMapOf<String, Job?>()

    fun getName(): String = REACT_CLASS

    fun initialize(roktTagId: String?, appVersion: String?, currentActivity: Activity?) {
        initRokt(roktTagId, appVersion, 4, currentActivity) { activity ->
            Rokt.init(
                roktTagId = requireNotNull(roktTagId),
                appVersion = requireNotNull(appVersion),
                activity = activity,
            )
        }
    }

    fun initializeWithFontFiles(
        roktTagId: String?,
        appVersion: String?,
        fontsMap: ReadableMap?,
        currentActivity: Activity?,
    ) {
        initRokt(roktTagId, appVersion, 4, currentActivity) { activity ->
            Rokt.init(
                roktTagId = requireNotNull(roktTagId),
                appVersion = requireNotNull(appVersion),
                activity = activity,
                fontPostScriptNames = HashSet(),
                fontFilePathMap = readableMapToMapOfStrings(fontsMap),
            )
        }
    }

    fun purchaseFinalized(placementId: String, catalogItemId: String, success: Boolean) {
        Rokt.purchaseFinalized(placementId, catalogItemId, success)
    }

    fun selectShoppableAds(identifier: String, attributes: ReadableMap?, currentActivity: Activity?) {
        Log.w("Rokt", "selectShoppableAds is not yet supported on Android")
    }

    fun selectShoppableAdsWithConfig(
        identifier: String,
        attributes: ReadableMap?,
        roktConfig: ReadableMap?,
        currentActivity: Activity?,
    ) {
        Log.w("Rokt", "selectShoppableAds is not yet supported on Android")
    }

    fun setEnvironmentToStage() {
        Rokt.setEnvironment(Rokt.Environment.Stage)
    }

    fun setEnvironmentToProd() {
        Rokt.setEnvironment(Prod)
    }

    fun setSessionId(sessionId: String) {
        Rokt.setSessionId(sessionId)
    }

    fun getSessionId(): String? = Rokt.getSessionId()

    fun setCustomBaseURL(url: String) {
        try {
            Rokt.setCustomBaseURL(URL(url))
        } catch (e: MalformedURLException) {
            Log.w("Rokt", "setCustomBaseURL failed. url is not a valid URL: $url", e)
        }
    }

    fun setPaymentCallbackURLScheme(scheme: String?) {
        // Backs the built-in PayPal device-pay redirect flow on iOS, where the host
        // app must register a URL scheme and forward deep links manually. Android's
        // SDK self-registers its own redirect activity (scoped to the host app's
        // package name) via manifest merging, so no host-app wiring is needed here.
        Log.w("Rokt", "setPaymentCallbackURLScheme is iOS only and is a no-op on Android")
    }

    fun handleURLCallback(url: String) {
        Log.w("Rokt", "handleURLCallback is iOS only and is a no-op on Android")
    }

    fun sendEvent(reactContext: ReactContext?, eventName: String, params: WritableMap?) {
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

    fun String.toColorMode(): RoktConfig.ColorMode = when (this) {
        "dark" -> RoktConfig.ColorMode.DARK
        "light" -> RoktConfig.ColorMode.LIGHT
        else -> RoktConfig.ColorMode.SYSTEM
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
        val cacheAttributes =
            if (cacheConfigMap?.hasKey("cacheAttributes") == true) {
                cacheConfigMap.getMap("cacheAttributes")?.toHashMap()?.mapValues { it.value as String }
            } else {
                null
            }
        return CacheConfig(
            cacheDurationInSeconds = cacheDurationInSeconds,
            cacheAttributes = cacheAttributes,
        )
    }

    fun startRoktEventListener(flow: Flow<RoktEvent>, currentActivity: Activity?, viewName: String? = null) {
        val activeJob = eventSubscriptions[viewName.orEmpty()]?.takeIf { it.isActive }
        if (activeJob != null) {
            return
        }
        val job =
            (currentActivity as? LifecycleOwner)?.lifecycleScope?.launch {
                (currentActivity as LifecycleOwner).repeatOnLifecycle(Lifecycle.State.CREATED) {
                    flow.collect { event ->
                        val params = Arguments.createMap()
                        var eventName: String
                        val placementId: String? =
                            when (event) {
                                RoktEvent.HideLoadingIndicator -> {
                                    eventName = "HideLoadingIndicator"
                                    null
                                }

                                is RoktEvent.OfferEngagement -> {
                                    eventName = "OfferEngagement"
                                    event.identifier
                                }

                                is RoktEvent.PlacementClosed -> {
                                    eventName = "PlacementClosed"
                                    event.identifier
                                }

                                is RoktEvent.PlacementCompleted -> {
                                    eventName = "PlacementCompleted"
                                    event.identifier
                                }

                                is RoktEvent.PlacementFailure -> {
                                    eventName = "PlacementFailure"
                                    event.identifier
                                }

                                is RoktEvent.PlacementInteractive -> {
                                    eventName = "PlacementInteractive"
                                    event.identifier
                                }

                                is RoktEvent.PlacementReady -> {
                                    eventName = "PlacementReady"
                                    event.identifier
                                }

                                is RoktEvent.PositiveEngagement -> {
                                    eventName = "PositiveEngagement"
                                    event.identifier
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
                                    event.identifier
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
                                    event.identifier
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
        init: (activity: Activity) -> Unit,
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
