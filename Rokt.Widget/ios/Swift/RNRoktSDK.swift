//
//  RNRoktSDK.swift
//  rokt-react-native-sdk
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
import RoktContracts
import Rokt_Widget
import UIKit

/// The Rokt SDK calls the bridge makes, for the Objective-C++ files (see RNRoktSwift.h). Keep each
/// @objc name in step with that header.
@objc(RNRoktSDK)
public final class RNRoktSDK: NSObject {
    @objc(setReactNativeFrameworkType)
    public static func setReactNativeFrameworkType() {
        Rokt.setFrameworkType(frameworkType: .ReactNative)
    }

    @objc(initializeWithTagId:)
    public static func initialize(tagId: String) {
        Rokt.initWith(roktTagId: tagId)
    }

    /// The handler receives each RoktEvent; RNRoktEventMapper turns it into a JavaScript payload.
    @objc(subscribeToGlobalEvents:)
    public static func subscribeToGlobalEvents(_ handler: @escaping (NSObject) -> Void) {
        Rokt.globalEvents { handler($0) }
    }

    @objc(subscribeToEventsWithIdentifier:handler:)
    public static func subscribeToEvents(identifier: String, handler: @escaping (NSObject) -> Void) {
        Rokt.events(identifier: identifier) { handler($0) }
    }

    /// Events reach JavaScript through the view subscription above, so no onEvent is passed here:
    /// it would deliver each event twice.
    @objc(selectPlacementsWithIdentifier:attributes:placements:config:)
    public static func selectPlacements(
        identifier: String,
        attributes: [String: String],
        placements: [String: UIView],
        config: NSObject?
    ) {
        let embeddedViews = placements.compactMapValues { $0 as? RoktEmbeddedView }
        if let config = config as? RoktConfig {
            Rokt.selectPlacements(
                identifier: identifier,
                attributes: attributes,
                placements: embeddedViews,
                config: config,
                placementOptions: nil,
                onEvent: nil
            )
        } else {
            Rokt.selectPlacements(
                identifier: identifier,
                attributes: attributes,
                placements: embeddedViews,
                onEvent: nil
            )
        }
    }

    @objc(selectShoppableAdsWithIdentifier:attributes:config:)
    public static func selectShoppableAds(identifier: String, attributes: [String: String], config: NSObject?) {
        Rokt.selectShoppableAds(
            identifier: identifier,
            attributes: attributes,
            config: config as? RoktConfig,
            onEvent: nil
        )
    }

    @objc(setStageEnvironment:)
    public static func setStageEnvironment(_ stage: Bool) {
        Rokt.setEnvironment(environment: stage ? .Stage : .Prod)
    }

    @objc(setSessionId:)
    public static func setSessionId(_ sessionId: String) {
        Rokt.setSessionId(sessionId: sessionId)
    }

    @objc(sessionId)
    public static func sessionId() -> String? {
        Rokt.getSessionId()
    }

    @objc(setCustomBaseURL:)
    public static func setCustomBaseURL(_ url: URL) {
        Rokt.setCustomBaseURL(url)
    }

    @objc(setBuiltInPayPalRedirectURLScheme:)
    public static func setBuiltInPayPalRedirectURLScheme(_ scheme: String?) {
        _ = Rokt.setBuiltInPayPalRedirectURLScheme(scheme)
    }

    @objc(handleURLCallback:)
    public static func handleURLCallback(_ url: URL) {
        _ = Rokt.handleURLCallback(with: url)
    }

    @objc(purchaseFinalizedWithIdentifier:catalogItemId:success:)
    public static func purchaseFinalized(identifier: String, catalogItemId: String, success: Bool) {
        Rokt.purchaseFinalized(identifier: identifier, catalogItemId: catalogItemId, success: success)
    }
}
