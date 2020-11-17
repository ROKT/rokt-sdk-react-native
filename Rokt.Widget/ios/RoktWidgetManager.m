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

@interface RoktNativeWidgetManager : RCTViewManager
@end

@implementation RoktNativeWidgetManager

RCT_EXPORT_MODULE(RoktNativeWidget)

- (UIView *)view
{
  return [[RoktEmbeddedView alloc] init];
//    return [RoktWidget new];
}

@end
