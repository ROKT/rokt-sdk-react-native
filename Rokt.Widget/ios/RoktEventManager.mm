//
//  RoktEventManager.m
//  rokt-sdk-react-native
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

#import "RoktEventManager.h"
#import "RNRoktSwift.h"

@implementation RoktEventManager
{
  bool hasListeners;
}

RCT_EXPORT_MODULE(RoktEventManager);

+ (id)allocWithZone:(NSZone *)zone {
    static RoktEventManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
}


- (NSArray<NSString *> *)supportedEvents
{
  return @[@"WidgetHeightChanges", @"RoktEvents"];
}

- (void)onWidgetHeightChanges:(CGFloat)widgetHeight placement:(NSString*) selectedPlacement
{
    if (hasListeners) {
        [self sendEventWithName:@"WidgetHeightChanges" body:@{@"height": [NSNumber numberWithDouble: widgetHeight],
                                                              @"selectedPlacement": selectedPlacement
        }];
    }
}

- (void)onRoktEvents:(NSObject * _Nonnull)event identifier:(NSString * _Nullable)identifier
{
    if (hasListeners) {
        NSDictionary *payload = [RNRoktEventMapper payloadForEvent:event viewName:identifier];
        NSNumber *height = [RNRoktEventMapper embeddedHeightForEvent:event];
        if (height != nil) {
            [self onWidgetHeightChanges:height.doubleValue placement:payload[@"placementId"]];
        }
        [self sendEventWithName:@"RoktEvents" body:payload];
    }
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeRoktEventManagerSpecJSI>(params);
}
#endif

@end
