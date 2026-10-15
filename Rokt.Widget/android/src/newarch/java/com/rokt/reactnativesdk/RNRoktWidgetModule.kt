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
    NativeRoktWidgetSpec(
        reactContext,
    ) {
    private val impl = RNRoktWidgetModuleImpl(reactContext)

    @ReactMethod
    override fun initialize(roktTagId: String?, appVersion: String?) {
        impl.initialize(roktTagId, appVersion, reactContext.currentActivity)
    }

    @ReactMethod
    override fun initializeWithFontFiles(roktTagId: String?, appVersion: String?, fontsMap: ReadableMap?) {
        impl.initializeWithFontFiles(roktTagId, appVersion, fontsMap, reactContext.currentActivity)
    }

    @ReactMethod
    override fun selectPlacements(identifier: String?, attributes: ReadableMap?, placeholders: ReadableMap?) {
        executeInternal(identifier, attributes, placeholders)
    }

    @ReactMethod
    override fun selectPlacementsWithConfig(
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
    override fun selectShoppableAds(identifier: String?, attributes: ReadableMap?) {
        selectShoppableAdsInternal(identifier, attributes)
    }

    @ReactMethod
    override fun selectShoppableAdsWithConfig(
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
        impl.selectShoppableAds(identifier, attributes, reactContext.currentActivity)
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
    override fun purchaseFinalized(identifier: String, catalogItemId: String, success: Boolean) {
        impl.purchaseFinalized(identifier, catalogItemId, success)
    }

    @ReactMethod
    override fun setSessionId(sessionId: String) {
        impl.setSessionId(sessionId)
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    override fun getSessionId(): String? = impl.getSessionId()

    @ReactMethod
    override fun setCustomBaseURL(url: String) {
        impl.setCustomBaseURL(url)
    }

    @ReactMethod
    override fun setPaymentCallbackURLScheme(scheme: String?) {
        impl.setPaymentCallbackURLScheme(scheme)
    }

    @ReactMethod
    override fun handleURLCallback(url: String) {
        impl.handleURLCallback(url)
    }
}
