//
//  RNRoktConfigFactory.swift
//  rokt-react-native-sdk
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
import RoktContracts

/// Builds the SDK's RoktConfig from the values the bridge reads out of the JavaScript config.
@objc(RNRoktConfigFactory)
public final class RNRoktConfigFactory: NSObject {
    /// - colorMode: "light" or "dark"; any other string means the system setting, and nil leaves
    ///   the SDK's default.
    /// - cache: whether the JavaScript config has a cacheConfig. Without one, caching stays off.
    /// - cacheDuration: in seconds; nil means the SDK's maximum.
    @objc(configWithColorMode:cache:cacheDuration:cacheAttributes:)
    public static func config(
        colorMode: String?,
        cache: Bool,
        cacheDuration: NSNumber?,
        cacheAttributes: [String: String]?
    ) -> NSObject {
        let builder = RoktConfig.Builder()
        if let colorMode {
            switch colorMode {
            case "light": builder.colorMode(.light)
            case "dark": builder.colorMode(.dark)
            default: builder.colorMode(.system)
            }
        }
        if cache {
            builder.cacheConfig(RoktConfig.CacheConfig(
                cacheDuration: cacheDuration?.doubleValue ?? RoktConfig.CacheConfig.maxCacheDuration,
                cacheAttributes: cacheAttributes
            ))
        }
        return builder.build()
    }
}
