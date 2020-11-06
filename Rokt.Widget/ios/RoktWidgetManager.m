//
//  RoktWidgetManager.m
//  rokt-sdk-react-native
//
//  Created by Danial Motahari on 4/11/20.
//

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import "RoktWidget.h"
#import <Rokt_Widget/Rokt-Widget-umbrella.h>

@interface RoktWidgetManager : RCTViewManager
@end

@implementation RoktWidgetManager

RCT_EXPORT_MODULE(RoktWidget)

- (UIView *)view
{
  return [[RoktEmbeddedView alloc] init];
//    return [RoktWidget new];
}

//RCT_EXPORT_METHOD(callNativeMethod:(nonnull NSNumber*) reactTag) {
//    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
//        RoktEmbeddedView *view = viewRegistry[reactTag];
//        if (!view || ![view isKindOfClass:[RoktEmbeddedView class]]) {
//            RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
//            return;
//        }
//
//    }];
//
//}

@end
