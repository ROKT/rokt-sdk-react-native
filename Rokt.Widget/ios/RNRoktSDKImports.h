//
//  RNRoktSDKImports.h
//  rokt-react-native-sdk
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

// For this package's sources only: the Rokt SDK's Objective-C headers, for every way an app can
// supply the SDK.
//  - CocoaPods: <RoktContracts/RoktContracts-Swift.h> and <Rokt_Widget/Rokt_Widget-Swift.h>.
//  - Swift Package Manager: Xcode generates the same headers outside any framework, so they are
//    found by name on the header search path.
//  - Last resort, module imports: these work in .m files only, because this pod builds .mm files
//    without C++ modules.
// Both are needed: Rokt_Widget-Swift.h only forward-declares the RoktContracts classes it uses, such
// as RoktConfig and RoktEmbeddedView, so their interfaces come from RoktContracts-Swift.h.
#if __has_include(<RoktContracts/RoktContracts-Swift.h>)
    #import <RoktContracts/RoktContracts-Swift.h>
#elif __has_include("RoktContracts-Swift.h")
    #import "RoktContracts-Swift.h"
#else
    @import RoktContracts;
#endif

#if __has_include(<Rokt_Widget/Rokt_Widget-Swift.h>)
    #import <Rokt_Widget/Rokt_Widget-Swift.h>
#elif __has_include("Rokt_Widget-Swift.h")
    #import "Rokt_Widget-Swift.h"
#else
    @import Rokt_Widget;
#endif
