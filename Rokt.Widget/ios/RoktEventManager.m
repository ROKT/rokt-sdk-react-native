//
//  RoktEventManager.m
//  rokt-sdk-react-native
//
//  Created by Danial Motahari on 17/11/20.
//

#import "RoktEventManager.h"

@implementation RoktEventManager

RCT_EXPORT_MODULE();

+ (id)allocWithZone:(NSZone *)zone {
    static RoktEventManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}


- (NSArray<NSString *> *)supportedEvents
{
  return @[@"WidgetHeightChanges"];
}

- (void)onWidgetHeightChanges:(CGFloat)widgetHeight placement:(NSString*) selectedPlacement
{
    [self sendEventWithName:@"WidgetHeightChanges" body:@{@"height": [NSNumber numberWithDouble: widgetHeight],
                                                          @"selectedPlacement": selectedPlacement
    }];
}

@end
