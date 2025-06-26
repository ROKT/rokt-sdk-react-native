//
//  RNRoktWidget.h
//  rokt-sdk-react-native
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

#import <Rokt_Widget/Rokt_Widget-Swift.h>
#import "RoktEventManager.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import <RNRoktWidgetSpec/RNRoktWidgetSpec.h>
#else
#import <React/RCTBridgeModule.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#ifdef RCT_NEW_ARCH_ENABLED
@interface RNRoktWidget : NSObject <NativeRoktWidgetSpec>
#else
@interface RNRoktWidget : NSObject <RCTBridgeModule>
#endif

@end

NS_ASSUME_NONNULL_END
