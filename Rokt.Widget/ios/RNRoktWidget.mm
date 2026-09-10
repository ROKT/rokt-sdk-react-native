//
//  RNRoktWidget.m
//  rokt-sdk-react-native
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

#import <SafariServices/SafariServices.h>
#import "RNRoktWidget.h"
#import <UIKit/UIKit.h>
#if __has_include(<RoktContracts/RoktContracts-Swift.h>)
    #import <RoktContracts/RoktContracts-Swift.h>
#endif
#import <Rokt_Widget/Rokt_Widget-Swift.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/RCTViewManager.h>
#import "RoktEventManager.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import "RoktNativeWidgetComponentView.h"
#import <RNRoktWidgetSpec/RNRoktWidgetSpec.h>
#endif // RCT_NEW_ARCH_ENABLED

@interface RNRoktWidget ()

@property (nonatomic, nullable) RoktEventManager *eventManager;

- (void)selectPlacementsWithIdentifier:(NSString *)identifier attributes:(NSDictionary *)attributes placeholders:(NSDictionary *)placeholders config:(RoktConfig *)config;

@end

@implementation RNRoktWidget

// Maps React tags to UIViews in both bridge and bridgeless modes.
@synthesize viewRegistry_DEPRECATED = _viewRegistry_DEPRECATED;

- (dispatch_queue_t)methodQueue
{
    // Placement selection mutates the embedded view hierarchy and must run on main.
    return dispatch_get_main_queue();
}

- (void)setMethodQueue:(dispatch_queue_t)methodQueue
{
    // No-op setter to satisfy TurboModule requirements
    // We always return the main queue
}


RCT_EXPORT_MODULE()
RCT_EXPORT_METHOD(initialize:(NSString *)roktTagId appVersion: (NSString *)fakeApp)
{
    if (roktTagId == nil) {
        RCTLog(@"roktTagId cannot be null");
        return;
    }
    [Rokt setFrameworkTypeWithFrameworkType: RoktFrameworkTypeReactNative];
    [self subscribeGlobalEvents];
    [Rokt initWithRoktTagId:roktTagId];
}

RCT_EXPORT_METHOD(initializeWithFonts:(NSString *)roktTagId appVersion: (NSString * _Nullable)fakeApp fontPostScriptNames: (NSArray *)fontPostScriptNames)
{
    if (roktTagId == nil) {
        RCTLog(@"roktTagId cannot be null");
        return;
    }
    [self subscribeGlobalEvents];
    [Rokt initWithRoktTagId:roktTagId];
}

- (void)initializeWithFontFiles:(NSString *)roktTagId appVersion:(NSString *)appVersion fontsMap:(NSDictionary *)fontsMap {
    if (roktTagId == nil) {
        RCTLog(@"roktTagId cannot be null");
        return;
    }
    [self subscribeGlobalEvents];
    [Rokt initWithRoktTagId:roktTagId ];
}

RCT_EXPORT_METHOD(selectPlacements:(NSString *)identifier
                  attributes:(NSDictionary *)attributes
                  placeholders:(NSDictionary *)placeholders
                  )
{
    if (identifier == nil) {
        RCTLog(@"selectPlacements failed. identifier cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];

    // Legacy UI-manager blocks are unreliable in bridgeless mode and become no-ops
    // when React Native removes the legacy architecture. Resolve through the registry
    // React Native injects into bridge modules instead.
    RCTExecuteOnMainQueue(^{
        NSMutableDictionary *nativePlaceholders = [self resolvePlaceholders:placeholders];

        [self subscribeViewEvents:identifier];

        [Rokt selectPlacementsWithIdentifier:identifier
            attributes:finalAttributes
            placements:nativePlaceholders
            onEvent:nil
        ];
    });
}

#ifdef RCT_NEW_ARCH_ENABLED
RCT_EXPORT_METHOD(selectPlacementsWithConfig:(NSString *)identifier
                  attributes:(NSDictionary *)attributes
                  placeholders:(NSDictionary *)placeholders
                  roktConfig:(JS::NativeRoktWidget::RoktConfigType &)roktConfig
                  )
{
    if (identifier == nil) {
        RCTLog(@"selectPlacementsWithConfig failed. identifier cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];

    RoktConfig *config = [self buildRoktConfigFromSpec:roktConfig];
    [self selectPlacementsWithIdentifier:identifier attributes:finalAttributes placeholders:placeholders config:config];
}
#else
RCT_EXPORT_METHOD(selectPlacementsWithConfig:(NSString *)identifier
                  attributes:(NSDictionary *)attributes
                  placeholders:(NSDictionary *)placeholders
                  roktConfig:(NSDictionary *)roktConfig
                  )
{
    if (identifier == nil) {
        RCTLog(@"selectPlacementsWithConfig failed. identifier cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];

    RoktConfig *config = [self buildRoktConfigFromDict:roktConfig];
    [self selectPlacementsWithIdentifier:identifier attributes:finalAttributes placeholders:placeholders config:config];
}
#endif

RCT_EXPORT_METHOD(selectShoppableAds:(NSString *)identifier
                  attributes:(NSDictionary *)attributes)
{
    if (identifier == nil) {
        RCTLog(@"selectShoppableAds failed. identifier cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];
    [self subscribeViewEvents:identifier];
    [Rokt selectShoppableAdsWithIdentifier:identifier
        attributes:finalAttributes
        config:nil
        onEvent:nil
    ];
}

#ifdef RCT_NEW_ARCH_ENABLED
RCT_EXPORT_METHOD(selectShoppableAdsWithConfig:(NSString *)identifier
                  attributes:(NSDictionary *)attributes
                  roktConfig:(JS::NativeRoktWidget::RoktConfigType &)roktConfig)
{
    if (identifier == nil) {
        RCTLog(@"selectShoppableAdsWithConfig failed. identifier cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];
    RoktConfig *config = [self buildRoktConfigFromSpec:roktConfig];
    [self subscribeViewEvents:identifier];
    [Rokt selectShoppableAdsWithIdentifier:identifier
        attributes:finalAttributes
        config:config
        onEvent:nil
    ];
}
#else
RCT_EXPORT_METHOD(selectShoppableAdsWithConfig:(NSString *)identifier
                  attributes:(NSDictionary *)attributes
                  roktConfig:(NSDictionary *)roktConfig)
{
    if (identifier == nil) {
        RCTLog(@"selectShoppableAdsWithConfig failed. identifier cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];
    RoktConfig *config = [self buildRoktConfigFromDict:roktConfig];
    [self subscribeViewEvents:identifier];
    [Rokt selectShoppableAdsWithIdentifier:identifier
        attributes:finalAttributes
        config:config
        onEvent:nil
    ];
}
#endif

- (NSMutableDictionary*)convertToMutableDictionaryOfStrings:(NSDictionary*)attributes
{
    NSMutableDictionary *finalAttributes = [attributes mutableCopy];
    NSArray *keysForNullValues = [finalAttributes allKeysForObject:[NSNull null]];
    [finalAttributes removeObjectsForKeys:keysForNullValues];

    NSSet *keys = [finalAttributes keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return ![obj isKindOfClass:[NSString class]];
    }];

    [finalAttributes removeObjectsForKeys:[keys allObjects]];
    return finalAttributes;

}

- (RoktColorMode)stringToColorMode:(NSString*)colorString
{
    if ([colorString isEqualToString:@"light"]) {
        return RoktColorModeLight;
    }
    else if ([colorString isEqualToString:@"dark"]) {
        return RoktColorModeDark;
    }
    else {
        return RoktColorModeSystem;
    }
}

- (void)subscribeGlobalEvents
{
    self.eventManager = [RoktEventManager allocWithZone: nil];
    [Rokt globalEventsOnEvent:^(RoktEvent * _Nonnull roktEvent) {
        [self.eventManager onRoktEvents:roktEvent identifier:nil];
    }];
}

- (void)subscribeViewEvents:(NSString* _Nonnull) identifier
{
    if (self.eventManager == nil) {
        self.eventManager = [RoktEventManager allocWithZone: nil];
    }
    [Rokt eventsWithIdentifier:identifier onEvent:^(RoktEvent * _Nonnull roktEvent) {
        [self.eventManager onRoktEvents:roktEvent identifier:identifier];
    }];
}

RCT_EXPORT_METHOD(setEnvironmentToStage) {
    [Rokt setEnvironmentWithEnvironment: RoktEnvironmentStage];
}
RCT_EXPORT_METHOD(setEnvironmentToProd){
    [Rokt setEnvironmentWithEnvironment: RoktEnvironmentProd];
}

RCT_EXPORT_METHOD(setSessionId:(NSString *)sessionId) {
    [Rokt setSessionIdWithSessionId:sessionId];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getSessionId) {
    return [Rokt getSessionId];
}

RCT_EXPORT_METHOD(setCustomBaseURL:(NSString *)urlString) {
    if (urlString == nil) {
        RCTLog(@"setCustomBaseURL failed. urlString cannot be null");
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        RCTLog(@"setCustomBaseURL failed. urlString is not a valid URL: %@", urlString);
        return;
    }
    [Rokt setCustomBaseURL:url];
}

RCT_EXPORT_METHOD(setPaymentCallbackURLScheme:(NSString *)scheme) {
    // Backs the built-in PayPal device-pay redirect flow. See
    // Rokt.setBuiltInPayPalRedirectURLScheme in the native SDK for details.
    [Rokt setBuiltInPayPalRedirectURLScheme:scheme];
}

RCT_EXPORT_METHOD(handleURLCallback:(NSString *)urlString) {
    if (urlString == nil) {
        RCTLog(@"handleURLCallback failed. urlString cannot be null");
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        RCTLog(@"handleURLCallback failed. urlString is not a valid URL: %@", urlString);
        return;
    }
    [Rokt handleURLCallbackWith:url];
}

RCT_EXPORT_METHOD(purchaseFinalized:(NSString *)placementId
                  catalogItemId:(NSString *)catalogItemId
                  success:(BOOL)success)
{
    if (placementId == nil || catalogItemId == nil) {
        RCTLog(@"purchaseFinalized failed. placementId and catalogItemId cannot be null");
        return;
    }
    // Call the native iOS implementation
    [Rokt purchaseFinalizedWithIdentifier:placementId
                            catalogItemId:catalogItemId
                                success:success];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeRoktWidgetSpecJSI>(params);
}
#endif

// Main thread only: RCTViewRegistry reads the mounted native view hierarchy.
- (NSMutableDictionary *)resolvePlaceholders:(NSDictionary *)placeholders
{
    NSMutableDictionary *nativePlaceholders = [[NSMutableDictionary alloc]initWithCapacity:placeholders.count];

#ifdef RCT_NEW_ARCH_ENABLED
    Class componentViewClass = NSClassFromString(@"RoktNativeWidgetComponentView");
#endif

    for(id key in placeholders){
        id reactTagValue = [placeholders objectForKey:key];
        if (![reactTagValue isKindOfClass:[NSNumber class]]) {
            RCTLogError(@"Invalid react tag for placeholder %@ (reactTag %@). Found: %@",
                        key,
                        reactTagValue,
                        NSStringFromClass([reactTagValue class]));
            continue;
        }

        NSNumber *reactTag = (NSNumber *)reactTagValue;
        UIView *view = [_viewRegistry_DEPRECATED viewForReactTag:reactTag];
#ifdef RCT_NEW_ARCH_ENABLED
        // In New Arch, we may get either:
        // 1. RoktNativeWidgetComponentView (full Fabric mode - RN 0.81+)
        // 2. RoktEmbeddedView (interop mode - RN 0.77 and similar)
        if (componentViewClass && [view isKindOfClass:componentViewClass]) {
            // Full Fabric mode - extract the embedded view from the wrapper
            RoktNativeWidgetComponentView *wrapperView = (RoktNativeWidgetComponentView *)view;
            nativePlaceholders[key] = wrapperView.roktEmbeddedView;
        } else if ([view isKindOfClass:[RoktEmbeddedView class]]) {
            // Interop mode - use the view directly
            nativePlaceholders[key] = (RoktEmbeddedView *)view;
        } else {
            RCTLogError(@"Cannot find RoktNativeWidget for placeholder %@ (reactTag %@). Found: %@",
                        key,
                        reactTag,
                        view ? NSStringFromClass([view class]) : @"nil");
            continue;
        }
#else
        if (![view isKindOfClass:[RoktEmbeddedView class]]) {
            RCTLogError(@"Cannot find RoktEmbeddedView for placeholder %@ (reactTag %@). Found: %@",
                        key,
                        reactTag,
                        view ? NSStringFromClass([view class]) : @"nil");
            continue;
        }

        nativePlaceholders[key] = (RoktEmbeddedView *)view;
#endif // RCT_NEW_ARCH_ENABLED
    }

    return nativePlaceholders;
}

- (void)selectPlacementsWithIdentifier:(NSString *)identifier attributes:(NSDictionary *)attributes placeholders:(NSDictionary *)placeholders config:(RoktConfig *)config
{
    RCTExecuteOnMainQueue(^{
        NSMutableDictionary *nativePlaceholders = [self resolvePlaceholders:placeholders];

        [self subscribeViewEvents:identifier];

        [Rokt selectPlacementsWithIdentifier:identifier
            attributes:attributes
            placements:nativePlaceholders
            config:config
            placementOptions:nil
            onEvent:^(RoktEvent * _Nonnull event) {
                [self.eventManager onRoktEvents:event identifier:identifier];
            }
        ];
    });
}

#ifdef RCT_NEW_ARCH_ENABLED
- (RoktConfig*)buildRoktConfigFromSpec:(JS::NativeRoktWidget::RoktConfigType &)roktConfigSpec
{
    RoktConfigBuilder *builder = [[RoktConfigBuilder alloc] init];
    NSString *colorMode = roktConfigSpec.colorMode();
    if (colorMode != nil) {
        RoktColorMode value = [self stringToColorMode:colorMode];
        [builder colorMode:value];
    }

    std::optional<JS::NativeRoktWidget::CacheConfig> cacheConfigSpec = roktConfigSpec.cacheConfig();
    if (cacheConfigSpec.has_value()) {
        auto cacheConfigValue = cacheConfigSpec.value();
        NSDictionary *cacheAttributes = (NSDictionary *)cacheConfigValue.cacheAttributes();
        std::optional<double> duration = cacheConfigValue.cacheDurationInSeconds();

        NSTimeInterval cacheDurationInSeconds = duration.has_value() ? duration.value() : RoktCacheConfig.maxCacheDuration;

        RoktCacheConfig *cacheConfig = [[RoktCacheConfig alloc] initWithCacheDuration:cacheDurationInSeconds cacheAttributes:cacheAttributes];
        [builder cacheConfig:(cacheConfig)];
    }

    return [builder build];
}
#else
- (RoktConfig*)buildRoktConfigFromDict:(NSDictionary *)roktConfigDict
{
    RoktConfigBuilder *builder = [[RoktConfigBuilder alloc] init];
    NSString *colorMode = roktConfigDict[@"colorMode"];
    if (colorMode != nil) {
        RoktColorMode value = [self stringToColorMode:colorMode];
        [builder colorMode:value];
    }

    NSDictionary *cacheConfigDict = roktConfigDict[@"cacheConfig"];
    if (cacheConfigDict != nil) {
        NSDictionary *cacheAttributes = cacheConfigDict[@"cacheAttributes"];
        NSNumber *duration = cacheConfigDict[@"cacheDurationInSeconds"];

        NSTimeInterval cacheDurationInSeconds = duration != nil ? [duration doubleValue] : RoktCacheConfig.maxCacheDuration;

        RoktCacheConfig *cacheConfig = [[RoktCacheConfig alloc] initWithCacheDuration:cacheDurationInSeconds cacheAttributes:cacheAttributes];
        [builder cacheConfig:(cacheConfig)];
    }

    return [builder build];
}
#endif

@end
