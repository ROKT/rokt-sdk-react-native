
#import "RNRoktWidget.h"
#import <UIKit/UIKit.h>
#import "React/RCTLog.h"
#import <Rokt_Widget/Rokt_Widget-Swift.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTLog.h>
#import <React/RCTBridge.h>


@implementation RNRoktWidget

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
//    return dispatch_get_main_queue();
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
    RCTLog(@"haha #%@", placeholders.description);
    RCTLog(@"Something #%@", self.bridge.uiManager.description);
    
    NSMutableDictionary *nativePlaceholders = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    
//    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
//            RoktEmbeddedView *view = viewRegistry[reactTag];
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
        
        
        RCTLog(@"at last #%@", nativePlaceholders.description);
//            if (!view || ![view isKindOfClass:[RoktEmbeddedView class]]) {
//                RCTLogError(@"Cannot find NativeView with tag #%@", "123");
////                RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
//                return;
//    }
        
            [Rokt executeWithViewName:viewName attributes:attributes
                           placements:nativePlaceholders
                                onLoad:^{ callback(@[@"onLoad", [NSNull null]]);}
                             onUnLoad:^{
                                 RCTLogInfo(@"unloaded");
                             }
         onShouldShowLoadingIndicator:nil
         onShouldHideLoadingIndicator:nil
                 onEmbeddedSizeChange:nil];
        
    }];
    
    
            
    
    
    
    

}
@end
  
