#import <XCTest/XCTest.h>
#import "../../../Rokt.Widget/ios/RNRoktSDKImports.h"
#import "../../../Rokt.Widget/ios/RNRoktWidget.h"

// Implemented in RNRoktWidget.mm, Debug builds only.
@interface RNRoktWidget (DuplicateSDKTests)
+ (NSDictionary<NSString *, NSNumber *> *)imageCountsForClassNames:(NSArray<NSString *> *)classNames;
+ (NSArray<NSString *> *)sdkClassNames;
@end

/**
 * Guards the Debug-only check that warns when two copies of the Rokt SDK are loaded.
 */
@interface RNRoktDuplicateSDKTests : XCTestCase
@end

@implementation RNRoktDuplicateSDKTests

- (void)testLooksForTheRuntimeNamesOfTheSDKClasses
{
    // If the SDK renames either class, the check would silently look for a class that no longer
    // exists.
    NSArray<NSString *> *expected = @[ NSStringFromClass([Rokt class]), NSStringFromClass([RoktEmbeddedView class]) ];

    XCTAssertEqualObjects([RNRoktWidget sdkClassNames], expected);
}

- (void)testCountsOneCopyOfTheSDK
{
    NSArray<NSString *> *classNames = [RNRoktWidget sdkClassNames];
    NSDictionary<NSString *, NSNumber *> *counts = [RNRoktWidget imageCountsForClassNames:classNames];

    for (NSString *name in classNames) {
        XCTAssertEqualObjects(counts[name], @1, @"%@", name);
    }
}

- (void)testCountsZeroForAClassNoImageDefines
{
    NSDictionary<NSString *, NSNumber *> *counts = [RNRoktWidget imageCountsForClassNames:@[ @"RNRoktNoSuchClass" ]];

    XCTAssertEqualObjects(counts[@"RNRoktNoSuchClass"], @0);
}

@end
