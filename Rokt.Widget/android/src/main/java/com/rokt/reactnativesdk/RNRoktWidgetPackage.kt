package com.rokt.reactnativesdk

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.ModuleSpec
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import java.util.*

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
class RNRoktWidgetPackage : BaseReactPackage() {
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> =
        listOf(RNRoktWidgetModule(reactContext))

    override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? =
        if (name == RNRoktWidgetModuleImpl.REACT_CLASS) {
            RNRoktWidgetModule(reactContext)
        } else {
            null
        }

    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider = ReactModuleInfoProvider {
        val moduleInfos: MutableMap<String, ReactModuleInfo> =
            HashMap<String, ReactModuleInfo>()
        moduleInfos.put(
            RNRoktWidgetModuleImpl.REACT_CLASS,
            ReactModuleInfo(
                RNRoktWidgetModuleImpl.REACT_CLASS,
                RNRoktWidgetModuleImpl.REACT_CLASS,
                false, // canOverrideExistingModule
                false, // needsEagerInit
                false, // isCxxModule
                BuildConfig.IS_NEW_ARCHITECTURE_ENABLED, // isTurboModule
            ),
        )
        moduleInfos.toMap()
    }

    override fun getViewManagers(reactContext: ReactApplicationContext): List<ModuleSpec> = listOf(
        ModuleSpec.viewManagerSpec { RoktEmbeddedViewManager() },
    )
}
