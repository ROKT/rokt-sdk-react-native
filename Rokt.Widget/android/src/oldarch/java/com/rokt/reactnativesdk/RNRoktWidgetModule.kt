package com.rokt.reactnativesdk

import com.facebook.react.bridge.*

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
        impl.selectPlacements(identifier, attributes, placeholders, roktConfig)
    }

    override fun invalidate() {
        impl.invalidate()
        super.invalidate()
    }

    @ReactMethod
    fun selectShoppableAds(identifier: String?, attributes: ReadableMap?) {
        selectShoppableAdsInternal(identifier, attributes)
    }

    @ReactMethod
    fun selectShoppableAdsWithConfig(identifier: String?, attributes: ReadableMap?, roktConfig: ReadableMap?) {
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
        impl.selectShoppableAds(identifier, attributes, reactContext.currentActivity)
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

    @ReactMethod
    fun setSessionId(sessionId: String) {
        impl.setSessionId(sessionId)
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getSessionId(): String? = impl.getSessionId()

    @ReactMethod
    fun setCustomBaseURL(url: String) {
        impl.setCustomBaseURL(url)
    }

    @ReactMethod
    fun setPaymentCallbackURLScheme(scheme: String?) {
        impl.setPaymentCallbackURLScheme(scheme)
    }

    @ReactMethod
    fun handleURLCallback(url: String) {
        impl.handleURLCallback(url)
    }
}
