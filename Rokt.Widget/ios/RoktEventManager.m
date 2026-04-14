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
@import RoktContracts;
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

- (void)onRoktEvents:(RoktEvent * _Nonnull)event identifier:(NSString * _Nullable)identifier
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
         NSString *error;
         NSString *paymentProvider;
         NSDecimalNumber *quantity;
         NSDecimalNumber *totalPrice;
         NSDecimalNumber *unitPrice;

         if ([event isKindOfClass:[RoktEmbeddedSizeChanged class]]) {
            eventName = @"EmbeddedSizeChanged";
            placementId = ((RoktEmbeddedSizeChanged *)event).identifier;
            CGFloat widgetHeight = ((RoktEmbeddedSizeChanged *)event).updatedHeight;
            [self onWidgetHeightChanges:widgetHeight placement:placementId];
         } else if ([event isKindOfClass:[RoktShowLoadingIndicator class]]) {
             eventName = @"ShowLoadingIndicator";
         } else if ([event isKindOfClass:[RoktHideLoadingIndicator class]]) {
             eventName = @"HideLoadingIndicator";
         } else if ([event isKindOfClass:[RoktPlacementInteractive class]]) {
             placementId = ((RoktPlacementInteractive *)event).identifier;
             eventName = @"PlacementInteractive";
         } else if ([event isKindOfClass:[RoktPlacementReady class]]) {
             placementId = ((RoktPlacementReady *)event).identifier;
             eventName = @"PlacementReady";
         } else if ([event isKindOfClass:[RoktOfferEngagement class]]) {
             placementId = ((RoktOfferEngagement *)event).identifier;
             eventName = @"OfferEngagement";
         } else if ([event isKindOfClass:[RoktPositiveEngagement class]]) {
             placementId = ((RoktPositiveEngagement *)event).identifier;
             eventName = @"PositiveEngagement";
         } else if ([event isKindOfClass:[RoktPlacementClosed class]]) {
             placementId = ((RoktPlacementClosed *)event).identifier;
             eventName = @"PlacementClosed";
         } else if ([event isKindOfClass:[RoktPlacementCompleted class]]) {
             placementId = ((RoktPlacementCompleted *)event).identifier;
             eventName = @"PlacementCompleted";
         } else if ([event isKindOfClass:[RoktPlacementFailure class]]) {
             placementId = ((RoktPlacementFailure *)event).identifier;
             eventName = @"PlacementFailure";
         } else if ([event isKindOfClass:[RoktInitComplete class]]) {
             eventName = @"InitComplete";
             status = ((RoktInitComplete *)event).success ? @"true" : @"false";
         } else if ([event isKindOfClass:[RoktOpenUrl class]]) {
             eventName = @"OpenUrl";
             placementId = ((RoktOpenUrl *)event).identifier;
             url = ((RoktOpenUrl *)event).url;
         } else if ([event isKindOfClass:[RoktCartItemInstantPurchase class]]) {
             RoktCartItemInstantPurchase *cartEvent = (RoktCartItemInstantPurchase *)event;
             eventName = @"CartItemInstantPurchase";
             // Required properties
             placementId = cartEvent.identifier;
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
         } else if ([event isKindOfClass:[RoktCartItemInstantPurchaseInitiated class]]) {
             RoktCartItemInstantPurchaseInitiated *cartEvent = (RoktCartItemInstantPurchaseInitiated *)event;
             eventName = @"CartItemInstantPurchaseInitiated";
             placementId = cartEvent.identifier;
             catalogItemId = cartEvent.catalogItemId;
             cartItemId = cartEvent.cartItemId;
         } else if ([event isKindOfClass:[RoktCartItemInstantPurchaseFailure class]]) {
             RoktCartItemInstantPurchaseFailure *cartEvent = (RoktCartItemInstantPurchaseFailure *)event;
             eventName = @"CartItemInstantPurchaseFailure";
             placementId = cartEvent.identifier;
             catalogItemId = cartEvent.catalogItemId;
             error = cartEvent.error;
         } else if ([event isKindOfClass:[RoktCartItemDevicePay class]]) {
             RoktCartItemDevicePay *cartEvent = (RoktCartItemDevicePay *)event;
             eventName = @"CartItemDevicePay";
             placementId = cartEvent.identifier;
             paymentProvider = cartEvent.paymentProvider;
         } else if ([event isKindOfClass:[RoktInstantPurchaseDismissal class]]) {
             RoktInstantPurchaseDismissal *dismissEvent = (RoktInstantPurchaseDismissal *)event;
             eventName = @"InstantPurchaseDismissal";
             placementId = dismissEvent.identifier;
         }
         NSMutableDictionary *payload = [@{@"event": eventName} mutableCopy];
         if (identifier != nil) {
             [payload setObject:identifier forKey:@"viewName"];
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
         if (error != nil) {
             [payload setObject:error forKey:@"error"];
         }
         if (paymentProvider != nil) {
             [payload setObject:paymentProvider forKey:@"paymentProvider"];
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
