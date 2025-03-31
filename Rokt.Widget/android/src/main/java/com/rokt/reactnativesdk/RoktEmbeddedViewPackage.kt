package com.rokt.reactnativesdk

import RoktEmbeddedViewManager
import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.uimanager.ViewManager

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
class RoktEmbeddedViewPackage : BaseReactPackage() {
    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return listOf(RoktEmbeddedViewManager())
    }

    override fun getModule(
        s: String, reactApplicationContext: ReactApplicationContext
    ): NativeModule? {
        when (s) {
            RoktEmbeddedViewManager.REACT_CLASS -> RoktEmbeddedViewManager()
        }
        return null
    }

    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider = ReactModuleInfoProvider {
        mapOf(
            RoktEmbeddedViewManager.REACT_CLASS to ReactModuleInfo(
                name = RoktEmbeddedViewManager.REACT_CLASS,
                className = RoktEmbeddedViewManager.REACT_CLASS,
                canOverrideExistingModule = false, // canOverrideExistingModule
                needsEagerInit = false, // needsEagerInit
                isCxxModule = false, // isCxxModule
                isTurboModule = true // isTurboModule
            )
        )
    }
}
