//
//  RNRoktWidgetModuleProvider.mm
//  rokt-sdk-react-native
//
//  Copyright 2025 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

// Only compile for new architecture
#ifdef RCT_NEW_ARCH_ENABLED

#import <Foundation/Foundation.h>

// This file provides a placeholder for new architecture module registration
// The actual registration will be handled by React Native's codegen system

@interface RNRoktWidgetModuleProvider : NSObject
@end

@implementation RNRoktWidgetModuleProvider

+ (void)load {
    // Module will be automatically registered by React Native's codegen
    NSLog(@"[ROKT] iOS: New Architecture module provider loaded");
}

@end

#endif // RCT_NEW_ARCH_ENABLED
