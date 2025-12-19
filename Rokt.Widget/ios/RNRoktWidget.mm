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
#import <Rokt_Widget/Rokt_Widget-Swift.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridge.h>
#import "RoktEventManager.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import "RoktNativeWidgetComponentView.h"
#import <RNRoktWidgetSpec/RNRoktWidgetSpec.h>
#endif // RCT_NEW_ARCH_ENABLED

@interface RNRoktWidget ()

@property (nonatomic, nullable) RoktEventManager *eventManager;

- (void)executeRoktWithViewName:(NSString *)viewName attributes:(NSDictionary *)attributes placeholders:(NSDictionary *)placeholders config:(RoktConfig *)config;

@end

@implementation RNRoktWidget

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return self.bridge.uiManager.methodQueue;
}

- (void)setMethodQueue:(dispatch_queue_t)methodQueue
{
    // No-op setter to satisfy TurboModule requirements
    // We always return the UI manager's method queue
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

RCT_EXPORT_METHOD(execute:(NSString *)viewName
                  attributes:(NSDictionary *)attributes
                  placeholders:(NSDictionary *)placeholders
                  )
{
    if (viewName == nil) {
        RCTLog(@"Execute failed. ViewName cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {

        NSMutableDictionary *nativePlaceholders = [self getNativePlaceholders:placeholders viewRegistry:viewRegistry];

        [self subscribeViewEvents:viewName];

        [Rokt selectPlacementsWithIdentifier:viewName
            attributes:finalAttributes
            placements:nativePlaceholders
            onEvent:nil
        ];
    }];
}

#ifdef RCT_NEW_ARCH_ENABLED
RCT_EXPORT_METHOD(executeWithConfig:(NSString *)viewName
                  attributes:(NSDictionary *)attributes
                  placeholders:(NSDictionary *)placeholders
                  roktConfig:(JS::NativeRoktWidget::RoktConfigType &)roktConfig
                  )
{
    if (viewName == nil) {
        RCTLog(@"Execute failed. ViewName cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];

    RoktConfig *config = [self buildRoktConfigFromSpec:roktConfig];
    [self executeRoktWithViewName:viewName attributes:finalAttributes placeholders:placeholders config:config];
}
#else
RCT_EXPORT_METHOD(executeWithConfig:(NSString *)viewName
                  attributes:(NSDictionary *)attributes
                  placeholders:(NSDictionary *)placeholders
                  roktConfig:(NSDictionary *)roktConfig
                  )
{
    if (viewName == nil) {
        RCTLog(@"Execute failed. ViewName cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];

    RoktConfig *config = [self buildRoktConfigFromDict:roktConfig];
    [self executeRoktWithViewName:viewName attributes:finalAttributes placeholders:placeholders config:config];
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

- (ColorMode)stringToColorMode:(NSString*)colorString
{
    if ([colorString isEqualToString:@"light"]) {
        return ColorModeLight;
    }
    else if ([colorString isEqualToString:@"dark"]) {
        return ColorModeDark;
    }
    else {
        return ColorModeSystem;
    }
}

- (void)subscribeGlobalEvents
{
    self.eventManager = [RoktEventManager allocWithZone: nil];
    [Rokt globalEventsOnEvent:^(RoktEvent * _Nonnull roktEvent) {
        [self.eventManager onRoktEvents:roktEvent viewName:nil];
    }];
}

- (void)subscribeViewEvents:(NSString* _Nonnull) viewName
{
    if (self.eventManager == nil) {
        self.eventManager = [RoktEventManager allocWithZone: nil];
    }
    [Rokt eventsWithIdentifier:viewName onEvent:^(RoktEvent * _Nonnull roktEvent) {
        [self.eventManager onRoktEvents:roktEvent viewName:viewName];
    }];
}

RCT_EXPORT_METHOD(setEnvironmentToStage) {
    [Rokt setEnvironmentWithEnvironment: RoktEnvironmentStage];
}
RCT_EXPORT_METHOD(setEnvironmentToProd){
    [Rokt setEnvironmentWithEnvironment: RoktEnvironmentProd];
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
    self.bridge = params.instance.bridge;
    return std::make_shared<facebook::react::NativeRoktWidgetSpecJSI>(params);
}
#endif

- (NSMutableDictionary *)getNativePlaceholders:(NSDictionary *)placeholders viewRegistry:(NSDictionary<NSNumber *, UIView *> *)viewRegistry
{
    NSMutableDictionary *nativePlaceholders = [[NSMutableDictionary alloc]initWithCapacity:placeholders.count];

#ifdef RCT_NEW_ARCH_ENABLED
    Class componentViewClass = NSClassFromString(@"RoktNativeWidgetComponentView");
#endif

    for(id key in placeholders){
#ifdef RCT_NEW_ARCH_ENABLED
        // In New Arch, we may get either:
        // 1. RoktNativeWidgetComponentView (full Fabric mode - RN 0.81+)
        // 2. RoktEmbeddedView (interop mode - RN 0.77 and similar)
        UIView *view = viewRegistry[[placeholders objectForKey:key]];

        if (componentViewClass && [view isKindOfClass:componentViewClass]) {
            // Full Fabric mode - extract the embedded view from the wrapper
            RoktNativeWidgetComponentView *wrapperView = (RoktNativeWidgetComponentView *)view;
            nativePlaceholders[key] = wrapperView.roktEmbeddedView;
        } else if ([view isKindOfClass:[RoktEmbeddedView class]]) {
            // Interop mode - use the view directly
            nativePlaceholders[key] = (RoktEmbeddedView *)view;
        } else {
            RCTLogError(@"Cannot find RoktNativeWidget view with tag #%@. Found: %@", key, view ? NSStringFromClass([view class]) : @"nil");
            continue;
        }
#else
        RoktEmbeddedView *view = viewRegistry[[placeholders objectForKey:key]];
        if (!view || ![view isKindOfClass:[RoktEmbeddedView class]]) {
            RCTLogError(@"Cannot find RoktEmbeddedView with tag #%@", key);
            continue;
        }

        nativePlaceholders[key] = view;
#endif // RCT_NEW_ARCH_ENABLED
    }

    return nativePlaceholders;
}

- (void)executeRoktWithViewName:(NSString *)viewName attributes:(NSDictionary *)attributes placeholders:(NSDictionary *)placeholders config:(RoktConfig *)config
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        NSMutableDictionary *nativePlaceholders = [self getNativePlaceholders:placeholders viewRegistry:viewRegistry];

        [self subscribeViewEvents:viewName];

        [Rokt selectPlacementsWithIdentifier:viewName
            attributes:attributes
            placements:nativePlaceholders
            config:config
            onEvent:nil
        ];
    }];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (RoktConfig*)buildRoktConfigFromSpec:(JS::NativeRoktWidget::RoktConfigType &)roktConfigSpec
{
    Builder *builder = [[Builder alloc] init];
    NSString *colorMode = roktConfigSpec.colorMode();
    if (colorMode != nil) {
        ColorMode value = [self stringToColorMode:colorMode];
        [builder colorMode:value];
    }

    std::optional<JS::NativeRoktWidget::CacheConfig> cacheConfigSpec = roktConfigSpec.cacheConfig();
    if (cacheConfigSpec.has_value()) {
        auto cacheConfigValue = cacheConfigSpec.value();
        NSDictionary *cacheAttributes = (NSDictionary *)cacheConfigValue.cacheAttributes();
        std::optional<double> duration = cacheConfigValue.cacheDurationInSeconds();

        NSTimeInterval cacheDurationInSeconds = duration.has_value() ? duration.value() : CacheConfig.maxCacheDuration;

        CacheConfig *cacheConfig = [[CacheConfig alloc] initWithCacheDuration:cacheDurationInSeconds cacheAttributes:cacheAttributes];
        [builder cacheConfig:(cacheConfig)];
    }

    return [builder build];
}
#else
- (RoktConfig*)buildRoktConfigFromDict:(NSDictionary *)roktConfigDict
{
    Builder *builder = [[Builder alloc] init];
    NSString *colorMode = roktConfigDict[@"colorMode"];
    if (colorMode != nil) {
        ColorMode value = [self stringToColorMode:colorMode];
        [builder colorMode:value];
    }

    NSDictionary *cacheConfigDict = roktConfigDict[@"cacheConfig"];
    if (cacheConfigDict != nil) {
        NSDictionary *cacheAttributes = cacheConfigDict[@"cacheAttributes"];
        NSNumber *duration = cacheConfigDict[@"cacheDurationInSeconds"];

        NSTimeInterval cacheDurationInSeconds = duration != nil ? [duration doubleValue] : CacheConfig.maxCacheDuration;

        CacheConfig *cacheConfig = [[CacheConfig alloc] initWithCacheDuration:cacheDurationInSeconds cacheAttributes:cacheAttributes];
        [builder cacheConfig:(cacheConfig)];
    }

    return [builder build];
}
#endif

@end
