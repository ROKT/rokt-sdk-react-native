//
//  RNRoktEventMapper.swift
//  rokt-react-native-sdk
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import CoreGraphics
import Foundation
import RoktContracts

/// Turns the SDK's RoktEvent objects into the payloads JavaScript receives.
@objc(RNRoktEventMapper)
public final class RNRoktEventMapper: NSObject {
    /// The RoktEvents payload. An event type with no mapping gets an empty event name.
    @objc(payloadForEvent:viewName:)
    public static func payload(for event: NSObject, viewName: String?) -> [String: Any] {
        var payload = lifecycleFields(for: event)
            ?? placementFields(for: event)
            ?? purchaseFields(for: event)
            ?? [:]
        payload["event"] = payload["event"] ?? ""
        if let viewName {
            payload["viewName"] = viewName
        }
        return payload
    }

    /// The new height of an embedded placement, for the WidgetHeightChanges event; nil for any other
    /// event.
    @objc(embeddedHeightForEvent:)
    public static func embeddedHeight(for event: NSObject) -> NSNumber? {
        guard let event = event as? RoktEvent.EmbeddedSizeChanged else { return nil }
        return NSNumber(value: Double(event.updatedHeight))
    }

    private static func lifecycleFields(for event: NSObject) -> [String: Any]? {
        switch event {
        case let event as RoktEvent.InitComplete:
            return ["event": "InitComplete", "status": event.success ? "true" : "false"]
        case is RoktEvent.ShowLoadingIndicator:
            return ["event": "ShowLoadingIndicator"]
        case is RoktEvent.HideLoadingIndicator:
            return ["event": "HideLoadingIndicator"]
        case let event as RoktEvent.EmbeddedSizeChanged:
            return fields("EmbeddedSizeChanged", placementId: event.identifier)
        case let event as RoktEvent.OpenUrl:
            return fields("OpenUrl", placementId: event.identifier, ["url": event.url])
        default:
            return nil
        }
    }

    private static func placementFields(for event: NSObject) -> [String: Any]? {
        switch event {
        case let event as RoktEvent.PlacementInteractive:
            return fields("PlacementInteractive", placementId: event.identifier)
        case let event as RoktEvent.PlacementReady:
            return fields("PlacementReady", placementId: event.identifier)
        case let event as RoktEvent.OfferEngagement:
            return fields("OfferEngagement", placementId: event.identifier)
        case let event as RoktEvent.PositiveEngagement:
            return fields("PositiveEngagement", placementId: event.identifier)
        case let event as RoktEvent.PlacementClosed:
            return fields("PlacementClosed", placementId: event.identifier)
        case let event as RoktEvent.PlacementCompleted:
            return fields("PlacementCompleted", placementId: event.identifier)
        case let event as RoktEvent.PlacementFailure:
            return fields("PlacementFailure", placementId: event.identifier)
        default:
            return nil
        }
    }

    private static func purchaseFields(for event: NSObject) -> [String: Any]? {
        switch event {
        case let event as RoktEvent.CartItemInstantPurchase:
            return fields("CartItemInstantPurchase", placementId: event.identifier, [
                "cartItemId": event.cartItemId,
                "catalogItemId": event.catalogItemId,
                "currency": event.currency,
                "description": event.description,
                "linkedProductId": event.linkedProductId,
                "providerData": event.providerData,
                "quantity": event.quantity,
                "totalPrice": event.totalPrice,
                "unitPrice": event.unitPrice
            ])
        case let event as RoktEvent.CartItemInstantPurchaseInitiated:
            return fields("CartItemInstantPurchaseInitiated", placementId: event.identifier, [
                "catalogItemId": event.catalogItemId,
                "cartItemId": event.cartItemId
            ])
        case let event as RoktEvent.CartItemInstantPurchaseFailure:
            return fields("CartItemInstantPurchaseFailure", placementId: event.identifier, [
                "catalogItemId": event.catalogItemId,
                "error": event.error
            ])
        case let event as RoktEvent.CartItemDevicePay:
            return fields("CartItemDevicePay", placementId: event.identifier, [
                "paymentProvider": event.paymentProvider
            ])
        case let event as RoktEvent.InstantPurchaseDismissal:
            return fields("InstantPurchaseDismissal", placementId: event.identifier)
        default:
            return nil
        }
    }

    /// The payload fields for an event; nil values are left out, as JavaScript expects.
    private static func fields(_ name: String, placementId: String?, _ extra: [String: Any?] = [:]) -> [String: Any] {
        var fields = extra.compactMapValues { $0 }
        fields["event"] = name
        if let placementId {
            fields["placementId"] = placementId
        }
        return fields
    }
}
