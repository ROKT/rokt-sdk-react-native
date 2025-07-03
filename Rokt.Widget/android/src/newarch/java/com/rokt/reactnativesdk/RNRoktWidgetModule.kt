package com.rokt.reactnativesdk

import com.facebook.react.bridge.*
import com.facebook.react.uimanager.UIManagerHelper
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.Rokt.RoktEventHandler
import com.rokt.roktsdk.Rokt.RoktEventType
import com.rokt.roktsdk.Widget
import java.lang.ref.WeakReference
import java.util.concurrent.CountDownLatch

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
    NativeRoktWidgetSpec(
        reactContext,
    ) {
    private val impl = RNRoktWidgetModuleImpl(reactContext)

    @ReactMethod
    override fun initialize(roktTagId: String?, appVersion: String?) {
        impl.initialize(roktTagId, appVersion, currentActivity)
    }

    @ReactMethod
    override fun initializeWithFontFiles(roktTagId: String?, appVersion: String?, fontsMap: ReadableMap?) {
        impl.initializeWithFontFiles(roktTagId, appVersion, fontsMap, currentActivity)
    }

    @ReactMethod
    override fun execute(viewName: String?, attributes: ReadableMap?, placeholders: ReadableMap?) {
        executeInternal(viewName, attributes, placeholders)
    }

    @ReactMethod
    override fun executeWithConfig(
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

        impl.startRoktEventListener(Rokt.events(viewName), currentActivity, viewName)
        val config = roktConfig?.let { impl.buildRoktConfig(it) }

        // Process placeholders for Fabric
        val placeholdersMap = processPlaceholders(placeholders)

        // Execute Rokt with the placeholders we gathered
        Rokt.execute(
            viewName = viewName,
            attributes = impl.readableMapToMapOfStrings(attributes),
            callback = impl.createRoktCallback(),
            placeholders = placeholdersMap,
            config = config,
        )
    }

    @ReactMethod
    override fun execute2Step(viewName: String?, attributes: ReadableMap?, placeholders: ReadableMap?) {
        execute2StepInternal(viewName, attributes, placeholders)
    }

    @ReactMethod
    override fun execute2StepWithConfig(
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

        impl.startRoktEventListener(Rokt.events(viewName), currentActivity, viewName)
        val config = roktConfig?.let { impl.buildRoktConfig(it) }

        // Process placeholders for Fabric
        val placeholdersMap = processPlaceholders(placeholders)

        // Execute Rokt with the placeholders we gathered
        Rokt.execute2Step(
            viewName = viewName,
            attributes = impl.readableMapToMapOfStrings(attributes),
            callback = impl.createRoktCallback(),
            placeholders = placeholdersMap,
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

    /**
     * Process placeholders from ReadableMap to a map of Widgets for use with Rokt.
     * This method handles the Fabric-specific view resolution.
     */
    private fun processPlaceholders(placeholders: ReadableMap?): Map<String, WeakReference<Widget>> {
        val placeholdersMap = HashMap<String, WeakReference<Widget>>()

        if (placeholders != null) {
            // Use CountDownLatch to wait for UI thread processing
            val latch = CountDownLatch(1)

            // Run view resolution on UI thread
            UiThreadUtil.runOnUiThread {
                try {
                    val iterator = placeholders.keySetIterator()
                    while (iterator.hasNextKey()) {
                        val key = iterator.nextKey()
                        try {
                            // Get the tag value as an integer
                            val reactTag =
                                when {
                                    placeholders.getType(key) == ReadableType.Number ->
                                        placeholders.getDouble(key).toInt()
                                    else -> {
                                        impl.logDebug("Invalid view tag for key: $key")
                                        continue
                                    }
                                }

                            // Get the UIManager for this specific tag
                            val uiManager = UIManagerHelper.getUIManagerForReactTag(reactContext, reactTag)
                            if (uiManager == null) {
                                impl.logDebug("UIManager not found for tag: $reactTag")
                                continue
                            }

                            // Resolve the view using the manager (now on UI thread)
                            val view = uiManager.resolveView(reactTag)
                            if (view is Widget) {
                                placeholdersMap[key] = WeakReference(view)
                                impl.logDebug("Successfully found Widget for key: $key with tag: $reactTag")
                            } else {
                                impl.logDebug("View with tag $reactTag is not a Widget: ${view?.javaClass?.simpleName}")
                            }
                        } catch (e: Exception) {
                            impl.logDebug("Error processing placeholder for key $key: ${e.message}")
                            e.printStackTrace()
                        }
                    }
                } finally {
                    latch.countDown()
                }
            }

            try {
                // Wait for UI thread to finish processing
                latch.await()
            } catch (e: InterruptedException) {
                impl.logDebug("Interrupted while waiting for UI thread: ${e.message}")
            }
        }

        return placeholdersMap
    }

    @ReactMethod
    override fun setFulfillmentAttributes(attributes: ReadableMap?) {
        impl.setFulfillmentAttributes(attributes)
    }

    override fun getName(): String = impl.getName()

    @ReactMethod
    override fun setEnvironmentToStage() {
        impl.setEnvironmentToStage()
    }

    @ReactMethod
    override fun setEnvironmentToProd() {
        impl.setEnvironmentToProd()
    }

    @ReactMethod
    override fun setLoggingEnabled(enabled: Boolean) {
        impl.setLoggingEnabled(enabled)
    }

    @ReactMethod
    override fun purchaseFinalized(placementId: String, catalogItemId: String, success: Boolean) {
        impl.purchaseFinalized(placementId, catalogItemId, success)
    }
}
