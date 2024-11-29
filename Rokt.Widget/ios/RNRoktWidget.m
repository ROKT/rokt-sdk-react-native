//
//  RNRoktWidget.m
//  rokt-sdk-react-native
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

#import "RNRoktWidget.h"
#import <UIKit/UIKit.h>
#import "React/RCTLog.h"
#import <Rokt_Widget/Rokt_Widget-Swift.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTLog.h>
#import <React/RCTBridge.h>
#import "RoktEventManager.h"


@implementation RNRoktWidget

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return self.bridge.uiManager.methodQueue;
}


RCT_EXPORT_MODULE()
RCT_EXPORT_METHOD(initialize:(NSString *)roktTagId appVersion: (NSString * _Nullable)fakeApp)
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
    
    NSMutableDictionary *nativePlaceholders = [[NSMutableDictionary alloc]initWithCapacity:placeholders.count];
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        for(id key in placeholders){
            RoktEmbeddedView *view = viewRegistry[[placeholders objectForKey:key]];
            if (!view || ![view isKindOfClass:[RoktEmbeddedView class]]) {
                RCTLogError(@"Cannot find RoktEmbeddedView with tag #%@", key);
                return;
            }
            
            nativePlaceholders[key] = view;
        }

        [self subscribeViewEvents:viewName];

        [Rokt executeWithViewName:viewName attributes:finalAttributes
                       placements:nativePlaceholders
                           onLoad:^{ [self.eventManager onRoktCallbackReceived:@"onLoad"];}
                         onUnLoad:^{
	    [self.eventManager onRoktCallbackReceived:@"onUnLoad"];
            RCTLogInfo(@"unloaded");
        }
     onShouldShowLoadingIndicator:^{ [self.eventManager onRoktCallbackReceived:@"onShouldShowLoadingIndicator"];}
     onShouldHideLoadingIndicator:^{ [self.eventManager onRoktCallbackReceived:@"onShouldHideLoadingIndicator"];}
             onEmbeddedSizeChange:^(NSString *selectedPlacement, CGFloat widgetHeight){
            
            [self.eventManager onWidgetHeightChanges:widgetHeight placement:selectedPlacement];
            
        }];
        
    }];
}

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
    
    NSMutableDictionary *nativePlaceholders = [[NSMutableDictionary alloc]initWithCapacity:placeholders.count];

    NSMutableDictionary *configMap = [roktConfig mutableCopy];

    RoktConfig *config = [self buildRoktConfig:configMap];

    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        for(id key in placeholders){
            RoktEmbeddedView *view = viewRegistry[[placeholders objectForKey:key]];
            if (!view || ![view isKindOfClass:[RoktEmbeddedView class]]) {
                RCTLogError(@"Cannot find RoktEmbeddedView with tag #%@", key);
                return;
            }
            
            nativePlaceholders[key] = view;
        }
        
        [self subscribeViewEvents:viewName];

        [Rokt executeWithViewName:viewName attributes:finalAttributes
                       placements:nativePlaceholders
                       config:config
                           onLoad:^{ [self.eventManager onRoktCallbackReceived:@"onLoad"];}
                         onUnLoad:^{
	    [self.eventManager onRoktCallbackReceived:@"onUnLoad"];
            RCTLogInfo(@"unloaded");
        }
     onShouldShowLoadingIndicator:^{ [self.eventManager onRoktCallbackReceived:@"onShouldShowLoadingIndicator"];}
     onShouldHideLoadingIndicator:^{ [self.eventManager onRoktCallbackReceived:@"onShouldHideLoadingIndicator"];}
             onEmbeddedSizeChange:^(NSString *selectedPlacement, CGFloat widgetHeight){
            
            [self.eventManager onWidgetHeightChanges:widgetHeight placement:selectedPlacement];
            
        }];
        
    }];
}

RCT_EXPORT_METHOD(execute2Step:(NSString *)viewName
                  attributes:(NSDictionary *)attributes
                  placeholders:(NSDictionary *)placeholders
                  )
{
    if (viewName == nil) {
        RCTLog(@"Execute failed. ViewName cannot be null");
        return;
    }
    NSMutableDictionary *finalAttributes = [self convertToMutableDictionaryOfStrings:attributes];
    
    NSMutableDictionary *nativePlaceholders = [[NSMutableDictionary alloc]initWithCapacity:placeholders.count];
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        for(id key in placeholders){
            RoktEmbeddedView *view = viewRegistry[[placeholders objectForKey:key]];
            if (!view || ![view isKindOfClass:[RoktEmbeddedView class]]) {
                RCTLogError(@"Cannot find RoktEmbeddedView with tag #%@", key);
                return;
            }
            
            nativePlaceholders[key] = view;
        }
        
        [self subscribeViewEvents:viewName];
        
        [Rokt execute2stepWithViewName:viewName attributes:finalAttributes
                            placements:nativePlaceholders
                                onLoad:^{ [self.eventManager onRoktCallbackReceived:@"onLoad"];}
                              onUnLoad:^{
	    [self.eventManager onRoktCallbackReceived:@"onUnLoad"];
            RCTLogInfo(@"unloaded");
        }
          onShouldShowLoadingIndicator:^{ [self.eventManager onRoktCallbackReceived:@"onShouldShowLoadingIndicator"];}
     onShouldHideLoadingIndicator:^{ [self.eventManager onRoktCallbackReceived:@"onShouldHideLoadingIndicator"];}
                  onEmbeddedSizeChange:^(NSString *selectedPlacement, CGFloat widgetHeight){
            
            [self.eventManager onWidgetHeightChanges:widgetHeight placement:selectedPlacement];
            
        }
                               onEvent:^(RoktEventType roktEventType, RoktEventHandler* roktEventHandler){
            self.roktEventHandler = roktEventHandler;
            if (roktEventType == RoktEventTypeFirstPositiveEngagement) {
                RCTLogInfo(@"firstPositiveEvent was fired");
                [self.eventManager onFirstPositiveResponse];
            }
        }];
        
    }];
    
}

RCT_EXPORT_METHOD(execute2StepWithConfig:(NSString *)viewName
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
    
    NSMutableDictionary *nativePlaceholders = [[NSMutableDictionary alloc]initWithCapacity:placeholders.count];

     NSMutableDictionary *configMap = [self convertToMutableDictionaryOfStrings:roktConfig];

    RoktConfig *config = [self buildRoktConfig:configMap];
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        for(id key in placeholders){
            RoktEmbeddedView *view = viewRegistry[[placeholders objectForKey:key]];
            if (!view || ![view isKindOfClass:[RoktEmbeddedView class]]) {
                RCTLogError(@"Cannot find RoktEmbeddedView with tag #%@", key);
                return;
            }
            
            nativePlaceholders[key] = view;
        }
        
        self.eventManager = [RoktEventManager allocWithZone: nil];

        [Rokt eventsWithViewName:viewName onEvent:^(RoktEvent * roktEvent) {
            [self.eventManager onRoktEvents:roktEvent viewName:viewName];
        }];
        
        [Rokt execute2stepWithViewName:viewName attributes:finalAttributes
                            placements:nativePlaceholders
                            config:config
                                onLoad:^{ [self.eventManager onRoktCallbackReceived:@"onLoad"];}
                              onUnLoad:^{
	    [self.eventManager onRoktCallbackReceived:@"onUnLoad"];
            RCTLogInfo(@"unloaded");
        }
          onShouldShowLoadingIndicator:^{ [self.eventManager onRoktCallbackReceived:@"onShouldShowLoadingIndicator"];}
     onShouldHideLoadingIndicator:^{ [self.eventManager onRoktCallbackReceived:@"onShouldHideLoadingIndicator"];}
                  onEmbeddedSizeChange:^(NSString *selectedPlacement, CGFloat widgetHeight){
            
            [self.eventManager onWidgetHeightChanges:widgetHeight placement:selectedPlacement];
            
        }
                               onEvent:^(RoktEventType roktEventType, RoktEventHandler* roktEventHandler){
            self.roktEventHandler = roktEventHandler;
            if (roktEventType == RoktEventTypeFirstPositiveEngagement) {
                RCTLogInfo(@"firstPositiveEvent was fired");
                [self.eventManager onFirstPositiveResponse];
            }
        }];
        
    }];
    
}

RCT_EXPORT_METHOD(setFulfillmentAttributes:(NSDictionary *)attributes) {
    if (self.roktEventHandler != nil) {
        RCTLogInfo(@"calling setFulfillmentAttributesWithAttributes");
        [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
            [self.roktEventHandler setFulfillmentAttributesWithAttributes:attributes];
        }];
    }
    if (self.eventManager != nil && self.eventManager.firstPositiveEngagement != nil) {
        [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
            [self.eventManager.firstPositiveEngagement setFulfillmentAttributesWithAttributes:attributes];
        }];
    }
}

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

- (RoktConfig*)buildRoktConfig:(NSDictionary*)config
{
    Builder *builder = [[Builder alloc] init];
    NSMutableDictionary *configMap = [self convertToMutableDictionaryOfStrings:config];
    NSString *colorMode = configMap[@"colorMode"];
    NSMutableDictionary *cacheConfig = config[@"cacheConfig"];
    
    if (colorMode != nil) {
        ColorMode value = [self stringToColorMode:colorMode];
        [builder colorMode:value];
    }
    if (cacheConfig != nil) {
        NSDictionary *cacheAttributes = cacheConfig[@"cacheAttributes"];
        NSNumber *duration = cacheConfig[@"cacheDurationInSeconds"];
        NSTimeInterval cacheDurationInSeconds = duration ? [duration doubleValue] : CacheConfig.maxCacheDuration;
        CacheConfig *cacheConfig = [[CacheConfig alloc] initWithCacheDuration:cacheDurationInSeconds cacheAttributes:cacheAttributes];
        [builder cacheConfig:(cacheConfig)];
    }
    return [builder build];
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
    [Rokt eventsWithViewName:viewName onEvent:^(RoktEvent * _Nonnull roktEvent) {
        [self.eventManager onRoktEvents:roktEvent viewName:viewName];
    }];
}

RCT_EXPORT_METHOD(setEnvironmentToStage) {
    [Rokt setEnvironmentWithEnvironment: RoktEnvironmentStage];
}
RCT_EXPORT_METHOD(setEnvironmentToProd){
    [Rokt setEnvironmentWithEnvironment: RoktEnvironmentProd];
}

RCT_EXPORT_METHOD(setLoggingEnabled: (BOOL *)enabled)
{
    [Rokt setLoggingEnabledWithEnable:enabled];
}

@end

