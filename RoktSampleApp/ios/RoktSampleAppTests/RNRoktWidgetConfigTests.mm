#import <XCTest/XCTest.h>
#import "../../../Rokt.Widget/ios/RNRoktWidget.h"
#if __has_include(<RoktContracts/RoktContracts-Swift.h>)
    #import <RoktContracts/RoktContracts-Swift.h>
#endif
#import <Rokt_Widget/Rokt_Widget-Swift.h>

// Implemented in RNRoktWidget.mm.
@interface RNRoktWidget (ConfigTests)
#ifdef RCT_NEW_ARCH_ENABLED
- (RoktConfig *)buildRoktConfigFromSpec:(JS::NativeRoktWidget::RoktConfigType &)roktConfigSpec;
#else
- (RoktConfig *)buildRoktConfigFromDict:(NSDictionary *)roktConfigDict;
#endif
@end

/**
 * The SDK takes cache attributes as [String: String], and Swift traps while bridging any
 * other value type. Values JS sends with another type must be dropped before the SDK call.
 */
@interface RNRoktWidgetConfigTests : XCTestCase
@end

@implementation RNRoktWidgetConfigTests

- (RoktConfig *)buildConfig:(NSDictionary *)json
{
#ifdef RCT_NEW_ARCH_ENABLED
    JS::NativeRoktWidget::RoktConfigType spec(json);
    return [[RNRoktWidget new] buildRoktConfigFromSpec:spec];
#else
    return [[RNRoktWidget new] buildRoktConfigFromDict:json];
#endif
}

- (void)testKeepsOnlyStringCacheAttributes
{
    NSDictionary *attributes = @{
        @"email" : @"a@example.com",
        @"missing" : [NSNull null],
        @"count" : @3,
        @"nested" : @{@"key" : @"value"},
        @"list" : @[ @"value" ],
    };

    RoktConfig *config = [self buildConfig:@{@"cacheConfig" : @{@"cacheAttributes" : attributes}}];

    XCTAssertEqualObjects(config.cacheConfig.cacheAttributes, @{@"email" : @"a@example.com"});
}

- (void)testIgnoresCacheAttributesThatAreNotAnObject
{
    RoktConfig *config = [self buildConfig:@{@"cacheConfig" : @{@"cacheAttributes" : @"a@example.com"}}];

    XCTAssertNil(config.cacheConfig.cacheAttributes);
}

#ifndef RCT_NEW_ARCH_ENABLED
// New Architecture converts colorMode before the builder runs; Rokt.tsx type-checks it.
- (void)testIgnoresColorModeThatIsNotAString
{
    RoktConfig *config = [self buildConfig:@{@"colorMode" : @1}];

    XCTAssertEqual(config.colorMode, RoktColorModeSystem);
}
#endif

@end
