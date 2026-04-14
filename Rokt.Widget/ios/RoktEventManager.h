//
//  RoktEventManager.m
//  rokt-sdk-react-native
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Rokt_Widget/Rokt_Widget-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoktEventManager : RCTEventEmitter <RCTBridgeModule>
+ (instancetype _Nonnull)allocWithZone:(NSZone * _Nullable)zone;
- (void)onWidgetHeightChanges:(CGFloat)widgetHeight placement:(NSString * _Nonnull)selectedPlacement;
- (void)onRoktEvents:(RoktEvent * _Nonnull)event identifier:(NSString * _Nullable)identifier;

@end

NS_ASSUME_NONNULL_END
