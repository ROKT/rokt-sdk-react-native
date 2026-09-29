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

// This Legacy ViewManager is needed for:
// 1. Old Architecture (Paper)
// 2. New Architecture in interop mode (RN 0.77 and similar)
// The name "RoktNativeWidget" matches the codegen component name.

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <React/RCTInvalidating.h>
#import "RoktPlaceholderRegistry.h"
@import RoktContracts;
#import <Rokt_Widget/Rokt_Widget-Swift.h>

#ifndef RCT_NEW_ARCH_ENABLED
// RoktEmbeddedView is closed to Objective-C subclassing. Paper invalidates removed
// views conforming to RCTInvalidating, even if an in-flight SDK request retains them.
@interface RoktEmbeddedView (RNPlaceholderRegistration) <RCTInvalidating>
@end
@implementation RoktEmbeddedView (RNPlaceholderRegistration)
- (void)invalidate
{
  [RoktPlaceholderRegistry unregisterView:self];
}
@end
#endif

@interface RoktNativeWidgetManager : RCTViewManager
@end

@implementation RoktNativeWidgetManager

RCT_EXPORT_MODULE(RoktNativeWidget)

RCT_CUSTOM_VIEW_PROPERTY(placeholderName, NSString, RoktEmbeddedView)
{
  [RoktPlaceholderRegistry registerView:view name:json ? [RCTConvert NSString:json] : nil];
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (UIView *)view
{
  return [[RoktEmbeddedView alloc] init];
}

@end
