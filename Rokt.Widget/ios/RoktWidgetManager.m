//
//  RoktWidgetManager.m
//  rokt-sdk-react-native
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
//

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <Rokt_Widget/Rokt-Widget-umbrella.h>

@interface RoktNativeWidgetManager : RCTViewManager
@end

@implementation RoktNativeWidgetManager

RCT_EXPORT_MODULE(RoktNativeWidget)

- (UIView *)view
{
  return [[RoktEmbeddedView alloc] init];
//    return [RoktWidget new];
}

@end
