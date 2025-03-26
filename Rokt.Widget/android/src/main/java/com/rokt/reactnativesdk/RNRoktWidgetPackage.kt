package com.rokt.reactnativesdk

import com.facebook.react.TurboReactPackage
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
class RNRoktWidgetPackage : TurboReactPackage() {
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> =
        listOf(RNRoktWidgetModule(reactContext))

    override fun getModule(
        name: String,
        reactContext: ReactApplicationContext
    ): NativeModule? {
        if (name == RNRoktWidgetModuleImpl.NAME) {
            return RNRoktWidgetModule(reactContext)
        } else {
            return null
        }
    }
    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
        return ReactModuleInfoProvider {
            val moduleInfos: MutableMap<String, ReactModuleInfo> =
                HashMap<String, ReactModuleInfo>()
            moduleInfos.put(
                RNRoktWidgetModuleImpl.NAME,
                ReactModuleInfo(
                    RNRoktWidgetModuleImpl.NAME,
                    RNRoktWidgetModuleImpl.NAME,
                    false,  // canOverrideExistingModule
                    false,  // needsEagerInit
                    true,  // hasConstants
                    false,  // isCxxModule
                    true // isTurboModule
                )
            )
            moduleInfos.toMap()
        }
    }
}
