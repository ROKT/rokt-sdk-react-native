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

- (void)onRoktEvents:(RoktEvent * _Nonnull)event viewName:(NSString * _Nullable)viewName
{
     if (hasListeners) {
         NSString *placementId;
         NSString *eventName = @"";
         NSString *status;
         NSString *url;
         NSString *cartItemId;
         NSString *catalogItemId;
         NSString *currency;
         NSString *itemDescription;
         NSString *linkedProductId;
         NSString *providerData;
         NSDecimalNumber *quantity;
         NSDecimalNumber *totalPrice;
         NSDecimalNumber *unitPrice;
         
         if ([event isKindOfClass:[EmbeddedSizeChanged class]]) {
            eventName = @"EmbeddedSizeChanged";
            placementId = ((EmbeddedSizeChanged *)event).placementId;
            CGFloat widgetHeight = ((EmbeddedSizeChanged *)event).updatedHeight;
            [self onWidgetHeightChanges:widgetHeight placement:placementId];
         } else if ([event isKindOfClass:[ShowLoadingIndicator class]]) {
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
         } else if ([event isKindOfClass:[InitComplete class]]) {
             eventName = @"InitComplete";
             status = ((InitComplete *)event).success ? @"true" : @"false";
         } else if ([event isKindOfClass:[OpenUrl class]]) {
             eventName = @"OpenUrl";
             placementId = ((OpenUrl *)event).placementId;
             url = ((OpenUrl *)event).url;
         } else if ([event isKindOfClass:[CartItemInstantPurchase class]]) {
             CartItemInstantPurchase *cartEvent = (CartItemInstantPurchase *)event;
             eventName = @"CartItemInstantPurchase";
             // Required properties
             placementId = cartEvent.placementId;
             cartItemId = cartEvent.cartItemId;
             catalogItemId = cartEvent.catalogItemId;
             currency = cartEvent.currency;
             providerData = cartEvent.providerData;
             // Optional properties
             linkedProductId = cartEvent.linkedProductId;
             // Overridden description property
             itemDescription = cartEvent.description;
             // Decimal properties
             quantity = cartEvent.quantity;
             totalPrice = cartEvent.totalPrice;
             unitPrice = cartEvent.unitPrice;
         }
         NSMutableDictionary *payload = [@{@"event": eventName} mutableCopy];
         if (viewName != nil) {
             [payload setObject:viewName forKey:@"viewName"];
         }
         if (placementId != nil) {
             [payload setObject:placementId forKey:@"placementId"];
         }
         if (status != nil) {
             [payload setObject:status forKey:@"status"];
         }
         if (url != nil) {
             [payload setObject:url forKey:@"url"];
         }
         if (cartItemId != nil) {
             [payload setObject:cartItemId forKey:@"cartItemId"];
         }
         if (catalogItemId != nil) {
             [payload setObject:catalogItemId forKey:@"catalogItemId"];
         }
         if (currency != nil) {
             [payload setObject:currency forKey:@"currency"];
         }
         if (itemDescription != nil) {
             [payload setObject:itemDescription forKey:@"description"];
         }
         if (linkedProductId != nil) {
             [payload setObject:linkedProductId forKey:@"linkedProductId"];
         }
         if (providerData != nil) {
             [payload setObject:providerData forKey:@"providerData"];
         }
         if (quantity != nil) {
             [payload setObject:quantity forKey:@"quantity"];
         }
         if (totalPrice != nil) {
             [payload setObject:totalPrice forKey:@"totalPrice"];
         }
         if (unitPrice != nil) {
             [payload setObject:unitPrice forKey:@"unitPrice"];
         }

         [self sendEventWithName:@"RoktEvents" body:payload];
     }
}

@end
