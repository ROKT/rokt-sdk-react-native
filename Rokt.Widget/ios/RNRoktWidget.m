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
    [Rokt initWithRoktTagId:roktTagId];
}
RCT_EXPORT_METHOD(execute:(NSString *)viewName
                  attributes:(NSDictionary *)attributes
                  placeholders:(NSDictionary *)placeholders
                  callback:(RCTResponseSenderBlock)callback
                )
{
    NSMutableDictionary *nativePlaceholders = [[NSMutableDictionary alloc]initWithCapacity:10];

    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        for(id key in placeholders){
            RoktEmbeddedView *view = viewRegistry[[placeholders objectForKey:key]];
            if (!view || ![view isKindOfClass:[RoktEmbeddedView class]]) {
                RCTLogError(@"Cannot find RoktEmbeddedView with tag #%@", key);
                return;
            } else {
                RCTLog(@"yes #%@", key);
            }
            
            nativePlaceholders[key] = view;
            
        }
        
        RoktEventManager *event = [RoktEventManager allocWithZone: nil];

        
            [Rokt executeWithViewName:viewName attributes:attributes
                           placements:nativePlaceholders
                                onLoad:^{ callback(@[@"onLoad", [NSNull null]]);}
                             onUnLoad:^{
                                 RCTLogInfo(@"unloaded");
                             }
         onShouldShowLoadingIndicator:nil
         onShouldHideLoadingIndicator:nil
                 onEmbeddedSizeChange:^(NSString *selectedPlacement, CGFloat widgetHeight){
                
                [event onWidgetHeightChanges:widgetHeight placement:selectedPlacement];
    
            }];
        
    }];
    
    
            
    
    
    
    

}
@end
  
