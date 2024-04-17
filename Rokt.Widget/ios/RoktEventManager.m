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
#import <Rokt_Widget/Rokt_Widget-Swift.h>

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
  return @[@"WidgetHeightChanges", @"FirstPositiveResponse", @"RoktCallback", @"RoktEvents"];
}

- (void)onWidgetHeightChanges:(CGFloat)widgetHeight placement:(NSString*) selectedPlacement
{
    if (hasListeners) {
        [self sendEventWithName:@"WidgetHeightChanges" body:@{@"height": [NSNumber numberWithDouble: widgetHeight],
                                                              @"selectedPlacement": selectedPlacement
        }];
    }
}

- (void)onFirstPositiveResponse
{
    if (hasListeners) {
        [self sendEventWithName:@"FirstPositiveResponse" body:@{@"":@""}];
    }
}

- (void)onRoktCallbackReceived:(NSString*)eventValue
{
    if (hasListeners) {
        [self sendEventWithName:@"RoktCallback" body:@{@"callbackValue": eventValue}];
    }
}

- (void)onRoktEvents:(RoktEvent *)event viewName:(NSString *)viewName
{
     if (hasListeners) {
         NSString *placementId;
         NSString *eventName;
         if ([event isKindOfClass:[ShowLoadingIndicator class]]) {
             eventName = @"ShowLoadingIndicator";
         } else if ([event isKindOfClass:[HideLoadingIndicator class]]) {
             eventName = @"HideLoadingIndicator";
         } else if ([event isKindOfClass:[PlacementInteractive class]]) {
             placementId = ((PlacementInteractive *)event).placementId;
             eventName = @"PlacementInteractive";
         } else if ([event isKindOfClass:[PlacementReady class]]) {
             placementId = ((PlacementReady *)event).placementId;
             eventName = @"PlacementReady";
         } else if ([event isKindOfClass:[OfferEngagement class]]) {
             placementId = ((OfferEngagement *)event).placementId;
             eventName = @"OfferEngagement";
         } else if ([event isKindOfClass:[PositiveEngagement class]]) {
             placementId = ((PositiveEngagement *)event).placementId;
             eventName = @"PositiveEngagement";
         } else if ([event isKindOfClass:[PlacementClosed class]]) {
             placementId = ((PlacementClosed *)event).placementId;
             eventName = @"PlacementClosed";
         } else if ([event isKindOfClass:[PlacementCompleted class]]) {
             placementId = ((PlacementCompleted *)event).placementId;
             eventName = @"PlacementCompleted";
         } else if ([event isKindOfClass:[PlacementFailure class]]) {
             placementId = ((PlacementFailure *)event).placementId;
             eventName = @"PlacementFailure";
         } else if ([event isKindOfClass:[FirstPositiveEngagement class]]) {
             placementId = ((FirstPositiveEngagement *)event).placementId;
             eventName = @"FirstPositiveEngagement";
             self.firstPositiveEngagement = (FirstPositiveEngagement *)event;
         }
         NSMutableDictionary *payload = [@{@"event": eventName, @"viewName": viewName} mutableCopy];
         if (placementId != nil) {
             [payload setObject:placementId forKey:@"placementId"];
         }

         [self sendEventWithName:@"RoktEvents" body:payload];
     }
}

@end
