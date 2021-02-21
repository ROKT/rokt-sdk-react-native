//
//  RNRoktWidget.h
//  rokt-sdk-react-native
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif
#import <Rokt_Widget/Rokt_Widget-Swift.h>


@interface RNRoktWidget : NSObject <RCTBridgeModule>
    @property (nonatomic) RoktEventHandler *roktEventHandler;
@end
  
