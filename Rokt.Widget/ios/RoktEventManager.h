//
//  RoktEventManager.m
//  rokt-sdk-react-native
//
//  Created by Danial Motahari on 17/11/20.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RoktEventManager : RCTEventEmitter <RCTBridgeModule>
+ (id)allocWithZone:(NSZone *)zone;
- (void)onWidgetHeightChanges:(CGFloat)widgetHeight;
@end
