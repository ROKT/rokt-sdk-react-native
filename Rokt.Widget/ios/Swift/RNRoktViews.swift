//
//  RNRoktViews.swift
//  rokt-react-native-sdk
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import RoktContracts
import UIKit

/// The SDK's embedded view, for files that only see UIView.
@objc(RNRoktViews)
public final class RNRoktViews: NSObject {
    @objc(makeEmbeddedViewWithFrame:)
    public static func makeEmbeddedView(frame: CGRect) -> UIView {
        RoktEmbeddedView(frame: frame)
    }

    @objc(isEmbeddedView:)
    public static func isEmbeddedView(_ view: UIView?) -> Bool {
        view is RoktEmbeddedView
    }
}
