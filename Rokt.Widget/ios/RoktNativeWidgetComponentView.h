//
//  RoktNativeWidgetFabricViewManager.h
//  rokt-sdk-react-native
//
//  Copyright 2025 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

#ifdef RCT_NEW_ARCH_ENABLED
#import <SafariServices/SafariServices.h>
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef RoktNativeWidgetComponentView_h
#define RoktNativeWidgetComponentView_h

NS_ASSUME_NONNULL_BEGIN

@interface RoktNativeWidgetComponentView : RCTViewComponentView
// The Rokt SDK's RoktEmbeddedView.
@property (nonatomic, readonly) UIView *roktEmbeddedView;
@end

NS_ASSUME_NONNULL_END
#endif // RoktNativeWidgetComponentView_h
#endif // RCT_NEW_ARCH_ENABLED
