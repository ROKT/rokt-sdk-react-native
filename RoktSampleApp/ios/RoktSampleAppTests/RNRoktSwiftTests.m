#import <XCTest/XCTest.h>
#import "../../../Rokt.Widget/ios/RNRoktSDKImports.h"
#import "../../../Rokt.Widget/ios/RNRoktSwift.h"

/**
 * RNRoktSwift.h declares the Swift classes by hand. A Swift rename the header misses compiles,
 * then fails at runtime with an unrecognized selector, so check every declaration here.
 */
@interface RNRoktSwiftTests : XCTestCase
@end

@implementation RNRoktSwiftTests

- (void)testEveryDeclaredMethodExists
{
    NSDictionary<NSString *, NSArray<NSString *> *> *declared = @{
        @"RNRoktSDK" : @[
            @"setReactNativeFrameworkType",
            @"initializeWithTagId:",
            @"subscribeToGlobalEvents:",
            @"subscribeToEventsWithIdentifier:handler:",
            @"selectPlacementsWithIdentifier:attributes:placements:config:",
            @"selectShoppableAdsWithIdentifier:attributes:config:",
            @"setStageEnvironment:",
            @"setSessionId:",
            @"sessionId",
            @"setCustomBaseURL:",
            @"setBuiltInPayPalRedirectURLScheme:",
            @"handleURLCallback:",
            @"purchaseFinalizedWithIdentifier:catalogItemId:success:",
        ],
        @"RNRoktConfigFactory" : @[ @"configWithColorMode:cache:cacheDuration:cacheAttributes:" ],
        @"RNRoktEventMapper" : @[ @"payloadForEvent:viewName:", @"embeddedHeightForEvent:" ],
        @"RNRoktViews" : @[ @"makeEmbeddedViewWithFrame:", @"isEmbeddedView:" ],
    };
    for (NSString *className in declared) {
        Class cls = NSClassFromString(className);
        XCTAssertNotNil(cls, @"%@", className);
        for (NSString *selector in declared[className]) {
            XCTAssertTrue([cls respondsToSelector:NSSelectorFromString(selector)], @"+[%@ %@]", className, selector);
        }
    }
}

- (void)testEmbeddedViewsAreTheSDKsView
{
    UIView *view = [RNRoktViews makeEmbeddedViewWithFrame:CGRectMake(0, 0, 320, 0)];

    XCTAssertTrue([view isKindOfClass:[RoktEmbeddedView class]]);
    XCTAssertEqualWithAccuracy(view.frame.size.width, 320, 0.5);
    XCTAssertTrue([RNRoktViews isEmbeddedView:view]);
    XCTAssertFalse([RNRoktViews isEmbeddedView:[UIView new]]);
    XCTAssertFalse([RNRoktViews isEmbeddedView:nil]);
}

- (void)testConfigFactoryBuildsTheSDKsConfig
{
    id config = [RNRoktConfigFactory configWithColorMode:nil cache:NO cacheDuration:nil cacheAttributes:nil];

    XCTAssertTrue([config isKindOfClass:[RoktConfig class]]);
}

@end
