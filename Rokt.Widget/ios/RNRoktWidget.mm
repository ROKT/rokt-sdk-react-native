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
#import "RNRoktSwift.h"
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/RCTViewManager.h>
#import "RoktEventManager.h"
#import "RoktPlaceholderRegistry.h"
#if DEBUG
#import <objc/runtime.h>
#endif

#ifdef RCT_NEW_ARCH_ENABLED
#import <RNRoktWidgetSpec/RNRoktWidgetSpec.h>
#endif // RCT_NEW_ARCH_ENABLED

@interface RNRoktWidget ()

@property (nonatomic, nullable) RoktEventManager *eventManager;
@property (atomic) BOOL invalidated;
@property (nonatomic, strong) NSMutableSet<NSString *> *placeholderWaitKeys;
@property (nonatomic, copy) NSString *placeholderWaitPrefix;

- (void)selectPlacementsWithIdentifier:(NSString *)identifier attributes:(NSDictionary *)attributes placeholders:(NSDictionary *)placeholders config:(nullable NSObject *)config;

@end

@implementation RNRoktWidget

- (instancetype)init
{
    if ((self = [super init])) {
        _placeholderWaitKeys = [NSMutableSet new];
        _placeholderWaitPrefix = [NSUUID UUID].UUIDString;
#if DEBUG
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [RNRoktWidget warnIfSDKLoadedTwice];
        });
#endif
    }
    return self;
}

#if DEBUG
// Counts, per class name, the loaded images inside the app bundle that define it. System
// images are skipped: scanning them all takes tens of seconds, the bundle takes milliseconds.
+ (NSDictionary<NSString *, NSNumber *> *)imageCountsForClassNames:(NSArray<NSString *> *)classNames
{
    NSMutableDictionary<NSString *, NSNumber *> *counts = [NSMutableDictionary dictionary];
    for (NSString *name in classNames) {
        counts[name] = @0;
    }
    NSString *bundlePath = NSBundle.mainBundle.bundlePath;
    unsigned int imageCount = 0;
    const char **images = objc_copyImageNames(&imageCount);
    for (unsigned int i = 0; i < imageCount; i++) {
        if (![@(images[i]) hasPrefix:bundlePath]) {
            continue;
        }
        unsigned int classCount = 0;
        const char **classes = objc_copyClassNamesForImage(images[i], &classCount);
        for (unsigned int j = 0; j < classCount; j++) {
            NSString *name = @(classes[j]);
            if (counts[name] != nil) {
                counts[name] = @(counts[name].unsignedIntegerValue + 1);
            }
        }
        free(classes);
    }
    free(images);
    return counts;
}

// The Rokt SDK classes to look for: the SDK entry point and the embedded view from RoktContracts.
// Rokt is a Swift class with no Objective-C name of its own; objc_copyClassNamesForImage reports
// it by its demangled name, as NSStringFromClass does.
+ (NSArray<NSString *> *)sdkClassNames
{
    return @[ @"Rokt_Widget.Rokt", @"RoktEmbeddedView" ];
}

// Taking the Rokt SDK from both CocoaPods and Swift Package Manager links a second copy that
// builds and archives silently, then misbehaves at runtime. Say so early in development.
+ (void)warnIfSDKLoadedTwice
{
    NSArray<NSString *> *classNames = [self sdkClassNames];
    NSDictionary<NSString *, NSNumber *> *counts = [self imageCountsForClassNames:classNames];
    NSMutableArray<NSString *> *duplicates = [NSMutableArray array];
    for (NSString *name in classNames) {
        if (counts[name].unsignedIntegerValue > 1) {
            [duplicates addObject:[NSString stringWithFormat:@"%@ x%@", name, counts[name]]];
        }
    }
    if (duplicates.count > 0) {
        RCTLogError(@"[Rokt] The Rokt SDK is loaded more than once (%@). This happens when the SDK comes from both CocoaPods and Swift Package Manager. Take it from one of them only.", [duplicates componentsJoinedByString:@", "]);
    }
}
#endif

- (void)invalidate
{
    self.invalidated = YES;
    RCTExecuteOnMainQueue(^{
        for (NSString *key in self.placeholderWaitKeys) {
            [RoktPlaceholderRegistry cancelWaitForKey:key];
        }
        [self.placeholderWaitKeys removeAllObjects];
    });
}

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
    [RNRoktSDK setReactNativeFrameworkType];
    [self subscribeGlobalEvents];
    [RNRoktSDK initializeWithTagId:roktTagId];
}

RCT_EXPORT_METHOD(initializeWithFonts:(NSString *)roktTagId appVersion: (NSString * _Nullable)fakeApp fontPostScriptNames: (NSArray *)fontPostScriptNames)
{
    if (roktTagId == nil) {
        RCTLog(@"roktTagId cannot be null");
        return;
    }
    [self subscribeGlobalEvents];
    [RNRoktSDK initializeWithTagId:roktTagId];
}

- (void)initializeWithFontFiles:(NSString *)roktTagId appVersion:(NSString *)appVersion fontsMap:(NSDictionary *)fontsMap {
    if (roktTagId == nil) {
        RCTLog(@"roktTagId cannot be null");
        return;
    }
    [self subscribeGlobalEvents];
    [RNRoktSDK initializeWithTagId:roktTagId];
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

    [self selectPlacementsWithIdentifier:identifier attributes:finalAttributes placeholders:placeholders config:nil];
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

    NSObject *config = [self buildRoktConfigFromSpec:roktConfig];
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

    NSObject *config = [self buildRoktConfigFromDict:roktConfig];
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
    [RNRoktSDK selectShoppableAdsWithIdentifier:identifier attributes:finalAttributes config:nil];
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
    NSObject *config = [self buildRoktConfigFromSpec:roktConfig];
    [self subscribeViewEvents:identifier];
    [RNRoktSDK selectShoppableAdsWithIdentifier:identifier attributes:finalAttributes config:config];
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
    NSObject *config = [self buildRoktConfigFromDict:roktConfig];
    [self subscribeViewEvents:identifier];
    [RNRoktSDK selectShoppableAdsWithIdentifier:identifier attributes:finalAttributes config:config];
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

// The SDK expects [String: String]; JS can send any shape, and a non-string value traps.
- (NSDictionary *)dictionaryOfStringsOrNil:(id)value
{
    return [value isKindOfClass:[NSDictionary class]] ? [self convertToMutableDictionaryOfStrings:value] : nil;
}

- (void)subscribeGlobalEvents
{
    self.eventManager = [RoktEventManager allocWithZone: nil];
    [RNRoktSDK subscribeToGlobalEvents:^(NSObject *roktEvent) {
        [self.eventManager onRoktEvents:roktEvent identifier:nil];
    }];
}

- (void)subscribeViewEvents:(NSString* _Nonnull) identifier
{
    if (self.eventManager == nil) {
        self.eventManager = [RoktEventManager allocWithZone: nil];
    }
    [RNRoktSDK subscribeToEventsWithIdentifier:identifier handler:^(NSObject *roktEvent) {
        [self.eventManager onRoktEvents:roktEvent identifier:identifier];
    }];
}

RCT_EXPORT_METHOD(setEnvironmentToStage) {
    [RNRoktSDK setStageEnvironment:YES];
}
RCT_EXPORT_METHOD(setEnvironmentToProd){
    [RNRoktSDK setStageEnvironment:NO];
}

RCT_EXPORT_METHOD(setSessionId:(NSString *)sessionId) {
    [RNRoktSDK setSessionId:sessionId];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getSessionId) {
    return [RNRoktSDK sessionId];
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
    [RNRoktSDK setCustomBaseURL:url];
}

RCT_EXPORT_METHOD(setPaymentCallbackURLScheme:(NSString *)scheme) {
    // Backs the built-in PayPal device-pay redirect flow. See
    // Rokt.setBuiltInPayPalRedirectURLScheme in the native SDK for details.
    [RNRoktSDK setBuiltInPayPalRedirectURLScheme:scheme];
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
    [RNRoktSDK handleURLCallback:url];
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
    [RNRoktSDK purchaseFinalizedWithIdentifier:placementId catalogItemId:catalogItemId success:success];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeRoktWidgetSpecJSI>(params);
}
#endif

// Main thread only. Placeholders are looked up by name; the dictionary's values are not used.
- (NSMutableDictionary *)resolvePlaceholders:(NSDictionary *)placeholders
{
    NSMutableDictionary *resolved = [NSMutableDictionary new];
    for (NSString *name in placeholders) {
        UIView *view = [RoktPlaceholderRegistry viewForName:name];
        if ([RNRoktViews isEmbeddedView:view]) {
            resolved[name] = view;
        } else {
            RCTLogWarn(@"Cannot resolve placeholder %@", name);
        }
    }
    return resolved;
}

- (void)selectPlacementsWithIdentifier:(NSString *)identifier attributes:(NSDictionary *)attributes placeholders:(NSDictionary *)placeholders config:(NSObject *)config
{
    RCTExecuteOnMainQueue(^{
        if (self.invalidated) {
            return;
        }
        NSArray<NSString *> *names = placeholders.allKeys ?: @[];
        NSString *key = [self.placeholderWaitPrefix stringByAppendingFormat:@":%@", identifier];
        [self.placeholderWaitKeys addObject:key];
        __weak __typeof__(self) weakSelf = self;
        [RoktPlaceholderRegistry waitForNames:names key:key timeout:2.0 completion:^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.invalidated) {
                return;
            }
            [strongSelf.placeholderWaitKeys removeObject:key];
            NSMutableDictionary *nativePlaceholders = [strongSelf resolvePlaceholders:placeholders];
            [strongSelf subscribeViewEvents:identifier];
            [RNRoktSDK selectPlacementsWithIdentifier:identifier attributes:attributes
                placements:nativePlaceholders config:config];
        } discarded:^{
            // A newer request owns this key after replacement. Invalidation clears all keys.
            RCTLogInfo(@"Pending selectPlacements dropped for %@", identifier);
        }];
    });
}

#ifdef RCT_NEW_ARCH_ENABLED
- (NSObject *)buildRoktConfigFromSpec:(JS::NativeRoktWidget::RoktConfigType &)roktConfigSpec
{
    std::optional<JS::NativeRoktWidget::CacheConfig> cacheConfigSpec = roktConfigSpec.cacheConfig();
    NSNumber *cacheDuration = nil;
    NSDictionary *cacheAttributes = nil;
    if (cacheConfigSpec.has_value()) {
        auto cacheConfigValue = cacheConfigSpec.value();
        cacheAttributes = [self dictionaryOfStringsOrNil:cacheConfigValue.cacheAttributes()];
        std::optional<double> duration = cacheConfigValue.cacheDurationInSeconds();
        cacheDuration = duration.has_value() ? @(duration.value()) : nil;
    }
    return [RNRoktConfigFactory configWithColorMode:roktConfigSpec.colorMode()
                                              cache:cacheConfigSpec.has_value()
                                      cacheDuration:cacheDuration
                                    cacheAttributes:cacheAttributes];
}
#else
- (NSObject *)buildRoktConfigFromDict:(NSDictionary *)roktConfigDict
{
    id colorMode = roktConfigDict[@"colorMode"];
    NSDictionary *cacheConfigDict = roktConfigDict[@"cacheConfig"];
    BOOL cache = [cacheConfigDict isKindOfClass:[NSDictionary class]];
    id duration = cache ? cacheConfigDict[@"cacheDurationInSeconds"] : nil;
    return [RNRoktConfigFactory configWithColorMode:[colorMode isKindOfClass:[NSString class]] ? colorMode : nil
                                              cache:cache
                                      cacheDuration:[duration isKindOfClass:[NSNumber class]] ? duration : nil
                                    cacheAttributes:cache ? [self dictionaryOfStringsOrNil:cacheConfigDict[@"cacheAttributes"]] : nil];
}
#endif

@end
