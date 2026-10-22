#import <XCTest/XCTest.h>
#import <React/RCTLog.h>
#import <React/RCTView.h>
#import <React/UIView+React.h>
#import "../../../Rokt.Widget/ios/RNRoktSDKImports.h"
#import <objc/runtime.h>
#import "../../../Rokt.Widget/ios/RoktPlaceholderRegistry.h"
#import "../../../Rokt.Widget/ios/RoktLegacyEmbeddedView.h"
#import "../../../Rokt.Widget/ios/RNRoktWidget.h"
#import "../../../Rokt.Widget/ios/RNRoktSwift.h"

// Implemented in RNRoktWidget.mm.
@interface RNRoktWidget (PlaceholderTests)
- (NSMutableDictionary *)resolvePlaceholders:(NSDictionary *)placeholders;
- (void)selectPlacementsWithIdentifier:(NSString *)identifier attributes:(NSDictionary *)attributes placeholders:(NSDictionary *)placeholders config:(RoktConfig *)config;
- (void)subscribeViewEvents:(NSString *)identifier;
@end

@interface RoktSelectionProbe : RNRoktWidget
@property (nonatomic) NSInteger resolutions;
@property (nonatomic) NSInteger subscriptions;
@end
@implementation RoktSelectionProbe
- (NSMutableDictionary *)resolvePlaceholders:(NSDictionary *)placeholders
{
    self.resolutions += 1;
    return [NSMutableDictionary new];
}
- (void)subscribeViewEvents:(NSString *)identifier
{
    self.subscriptions += 1;
}
@end

@interface RNRoktWidgetPlaceholderTests : XCTestCase
@end

@implementation RNRoktWidgetPlaceholderTests {
    RNRoktWidget *_rokt;
    NSInteger _loggedErrorCount;
    NSMutableArray<NSString *> *_loggedErrors;
    NSMutableArray<NSNumber *> *_loggedLevels;
    RCTLogFunction _originalLogFunction;
}

- (void)setUp
{
    [super setUp];
    _rokt = [RNRoktWidget new];
    __weak __typeof__(self) weakSelf = self;

    _loggedErrorCount = 0;
    _loggedErrors = [NSMutableArray new];
    _loggedLevels = [NSMutableArray new];
    _originalLogFunction = RCTGetLogFunction();
    RCTSetLogFunction(^(RCTLogLevel level,
                        __unused RCTLogSource source,
                        __unused NSString *fileName,
                        __unused NSNumber *lineNumber,
                        NSString *message) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf && level >= RCTLogLevelWarning) {
            strongSelf->_loggedErrorCount++;
            [strongSelf->_loggedErrors addObject:message ?: @""];
            [strongSelf->_loggedLevels addObject:@(level)];
        }
    });
}

- (void)tearDown
{
    [RoktPlaceholderRegistry cancelAllWaits];
    RCTSetLogFunction(_originalLogFunction);
    _rokt = nil;
    [super tearDown];
}

- (void)testModuleUsesMainQueue
{
    XCTAssertEqual(_rokt.methodQueue, dispatch_get_main_queue());
}

- (void)testResolvesByNameWhateverTheValue
{
    RoktEmbeddedView *named = [RoktEmbeddedView new];
    [RoktPlaceholderRegistry registerView:named name:@"TestLocation1"];
    for (id value in @[ @0, @101, [NSNull null], @"101" ]) {
        XCTAssertEqual([_rokt resolvePlaceholders:@{@"TestLocation1": value}][@"TestLocation1"], named, @"%@", value);
    }
    XCTAssertEqual(_loggedErrorCount, 0, @"errors: %@", _loggedErrors);
    [RoktPlaceholderRegistry unregisterView:named];
}

- (void)testSkipsRegisteredViewOfUnexpectedClass
{
    UIView *plain = [UIView new];
    [RoktPlaceholderRegistry registerView:plain name:@"TestLocation1"];
    NSDictionary *resolved = [_rokt resolvePlaceholders:@{@"TestLocation1": @0}];
    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 1, @"errors: %@", _loggedErrors);
    XCTAssertEqual(_loggedLevels.firstObject.integerValue, RCTLogLevelWarning);
    [RoktPlaceholderRegistry unregisterView:plain];
}

- (void)testMissingNameLogsWarning
{
    NSDictionary *resolved = [_rokt resolvePlaceholders:@{@"TestMissingName": @0}];
    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 1);
    XCTAssertEqual(_loggedLevels.firstObject.integerValue, RCTLogLevelWarning);
}

- (void)testEmptyPlaceholdersResolveToEmptyDictionary
{
    NSDictionary *resolved = [_rokt resolvePlaceholders:@{}];

    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 0, @"errors: %@", _loggedErrors);
}

- (void)testDuplicateNamesAndRename
{
    UIView *lower = [UIView new];
    UIView *upper = [UIView new];
    [RoktPlaceholderRegistry registerView:lower name:@"TestLocation1"];
    [RoktPlaceholderRegistry registerView:upper name:@"TestLocation1"];
    XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation1"], upper);
    [RoktPlaceholderRegistry registerView:upper name:@"TestLocation2"];
    XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation1"], lower);
    XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation2"], upper);
    [RoktPlaceholderRegistry unregisterView:lower];
    [RoktPlaceholderRegistry unregisterView:upper];
    XCTAssertNil([RoktPlaceholderRegistry viewForName:@"TestLocation1"]);
}

- (void)testPrefersAttachedView
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 300, 600)];
    UIView *attached = [UIView new];
    UIView *detached = [UIView new];
    [window addSubview:attached];
    [RoktPlaceholderRegistry registerView:attached name:@"TestLocation1"];
    [RoktPlaceholderRegistry registerView:detached name:@"TestLocation1"];
    XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation1"], attached);
    [RoktPlaceholderRegistry unregisterView:attached];
    [RoktPlaceholderRegistry unregisterView:detached];
}

- (void)testRegistrationDefersCompletionBeyondMount
{
    XCTestExpectation *ready = [self expectationWithDescription:@"ready after mount"];
    __block BOOL insideMount = YES;
    [RoktPlaceholderRegistry waitForNames:@[@"TestLocation1"] key:@"page" timeout:1 completion:^{
        XCTAssertFalse(insideMount);
        [ready fulfill];
    } discarded:^{ XCTFail(@"Unexpected discard"); }];
    UIView *view = [UIView new];
    [RoktPlaceholderRegistry registerView:view name:@"TestLocation1"];
    insideMount = NO;
    [self waitForExpectations:@[ready] timeout:1];
    [RoktPlaceholderRegistry unregisterView:view];
}

- (void)testTimeoutProceedsWithAvailableViews
{
    UIView *view = [UIView new];
    [RoktPlaceholderRegistry registerView:view name:@"TestLocation1"];
    XCTestExpectation *ready = [self expectationWithDescription:@"timeout"];
    [RoktPlaceholderRegistry waitForNames:@[@"TestLocation1", @"missing"] key:@"page" timeout:0.03 completion:^{
        XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation1"], view);
        XCTAssertNil([RoktPlaceholderRegistry viewForName:@"missing"]);
        [ready fulfill];
    } discarded:^{ XCTFail(@"Unexpected discard"); }];
    [self waitForExpectations:@[ready] timeout:1];
    [RoktPlaceholderRegistry unregisterView:view];
}

- (void)testReplacementCancelsAlreadyQueuedCompletion
{
    XCTestExpectation *ready = [self expectationWithDescription:@"latest request"];
    XCTestExpectation *discarded = [self expectationWithDescription:@"old discarded"];
    [RoktPlaceholderRegistry waitForNames:@[] key:@"page" timeout:1 completion:^{
        XCTFail(@"Replaced callback must not execute");
    } discarded:^{ [discarded fulfill]; }];
    [RoktPlaceholderRegistry waitForNames:@[] key:@"page" timeout:1 completion:^{
        [ready fulfill];
    } discarded:^{ XCTFail(@"Latest must execute"); }];
    [self waitForExpectations:@[ready, discarded] timeout:1];
}

- (void)testCancellationIsScopedToItsKey
{
    XCTestExpectation *ready = [self expectationWithDescription:@"other module"];
    XCTestExpectation *discarded = [self expectationWithDescription:@"cancelled"];
    [RoktPlaceholderRegistry waitForNames:@[] key:@"module1:page" timeout:1 completion:^{
        XCTFail(@"Cancelled callback must not execute");
    } discarded:^{ [discarded fulfill]; }];
    [RoktPlaceholderRegistry waitForNames:@[] key:@"module2:page" timeout:1 completion:^{
        [ready fulfill];
    } discarded:^{ XCTFail(@"Other module must execute"); }];
    [RoktPlaceholderRegistry cancelWaitForKey:@"module1:page"];
    [self waitForExpectations:@[ready, discarded] timeout:1];
}

- (void)testPaperRemovalUnregistersRetainedView
{
    RoktLegacyEmbeddedView *wrapper = [RoktLegacyEmbeddedView new];
    wrapper.placeholderName = @"TestLocation1";
    UIView *retained = wrapper.roktEmbeddedView;
    [wrapper invalidate];
    XCTAssertNil([RoktPlaceholderRegistry viewForName:@"TestLocation1"]);
    XCTAssertNotNil(retained);
}

- (void)testInteropRemovalWaitsForReplacementEvenWhenSDKRetainsView
{
    UIView *parent = [UIView new];
    UIView *retained;
    __weak RoktLegacyEmbeddedView *releasedWrapper;
    @autoreleasepool {
        RoktLegacyEmbeddedView *wrapper = [RoktLegacyEmbeddedView new];
        wrapper.placeholderName = @"TestLocation1";
        [parent addSubview:wrapper];
        retained = wrapper.roktEmbeddedView;
        releasedWrapper = wrapper;
        // Interop teardown removes and releases its wrapper without calling invalidate.
        [wrapper removeFromSuperview];
    }
    XCTAssertNil(releasedWrapper);
    XCTAssertNil([RoktPlaceholderRegistry viewForName:@"TestLocation1"]);

    RoktLegacyEmbeddedView *replacement = [RoktLegacyEmbeddedView new];
    XCTestExpectation *ready = [self expectationWithDescription:@"replacement mounted"];
    [RoktPlaceholderRegistry waitForNames:@[@"TestLocation1"] key:@"page" timeout:1 completion:^{
        XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation1"], replacement.roktEmbeddedView);
        [ready fulfill];
    } discarded:^{ XCTFail(@"Unexpected discard"); }];
    dispatch_async(dispatch_get_main_queue(), ^{
        replacement.placeholderName = @"TestLocation1";
        [parent addSubview:replacement];
    });
    [self waitForExpectations:@[ready] timeout:1];
    [replacement invalidate];
    XCTAssertNotNil(retained);
}

- (void)testLegacyWrapperRestoresEarlierViewAndSupportsReattachment
{
    UIWindow *parent = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 330, 600)];
    RoktLegacyEmbeddedView *lower = [RoktLegacyEmbeddedView new];
    RoktLegacyEmbeddedView *upper = [RoktLegacyEmbeddedView new];
    lower.placeholderName = @"TestLocation1";
    upper.placeholderName = @"TestLocation1";
    [parent addSubview:lower];
    [parent addSubview:upper];
    XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation1"], upper.roktEmbeddedView);
    [upper removeFromSuperview];
    XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation1"], lower.roktEmbeddedView);
    [parent addSubview:upper];
    XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation1"], upper.roktEmbeddedView);
    [lower removeFromSuperview];
    [parent addSubview:lower];
    XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestLocation1"], upper.roktEmbeddedView,
                   @"Reattaching an older clipped view must not change registration order");
    [lower invalidate];
    [upper invalidate];
}

- (void)testClippedMountedPlaceholderRemainsResolvableWithoutWaiting
{
    RCTView *parent = [[RCTView alloc] initWithFrame:CGRectMake(0, 0, 330, 300)];
    RoktLegacyEmbeddedView *wrapper = [[RoktLegacyEmbeddedView alloc] initWithFrame:CGRectMake(0, 500, 330, 100)];
    wrapper.placeholderName = @"TestClippedLocation";
    [parent insertReactSubview:wrapper atIndex:0];
    [parent addSubview:wrapper];
    parent.clipsToBounds = YES;
    parent.removeClippedSubviews = YES;
    [parent updateClippedSubviews];

    XCTAssertNil(wrapper.superview);
    XCTAssertTrue([parent.reactSubviews containsObject:wrapper], @"Clipping must retain the mounted React child");
    XCTAssertEqual([_rokt resolvePlaceholders:@{@"TestClippedLocation": @0}][@"TestClippedLocation"], wrapper.roktEmbeddedView);
    XCTestExpectation *ready = [self expectationWithDescription:@"clipped view already registered"];
    [RoktPlaceholderRegistry waitForNames:@[@"TestClippedLocation"] key:@"clipped" timeout:10 completion:^{
        [ready fulfill];
    } discarded:^{ XCTFail(@"Unexpected discard"); }];
    [self waitForExpectations:@[ready] timeout:1];

    wrapper.frame = CGRectMake(0, 0, 330, 100);
    [parent updateClippedSubviews];
    XCTAssertEqual(wrapper.superview, parent);
    XCTAssertEqual([RoktPlaceholderRegistry viewForName:@"TestClippedLocation"], wrapper.roktEmbeddedView);
    [wrapper invalidate];
    XCTAssertNil([RoktPlaceholderRegistry viewForName:@"TestClippedLocation"]);
}

- (void)testDiscardingUnattachedWrapperUnregistersRetainedSDKView
{
    UIView *retained;
    @autoreleasepool {
        RoktLegacyEmbeddedView *wrapper = [RoktLegacyEmbeddedView new];
        wrapper.placeholderName = @"TestLocation1";
        retained = wrapper.roktEmbeddedView;
    }
    XCTAssertNil([RoktPlaceholderRegistry viewForName:@"TestLocation1"]);
    XCTAssertNotNil(retained);
}

- (void)testLegacyWrapperResolvesByNameAndPreservesSDKHeight
{
    RoktLegacyEmbeddedView *wrapper = [[RoktLegacyEmbeddedView alloc] initWithFrame:CGRectMake(0, 0, 330, 0)];
    wrapper.placeholderName = @"TestLocation1";
    XCTAssertEqual([_rokt resolvePlaceholders:@{@"TestLocation1": @0}][@"TestLocation1"], wrapper.roktEmbeddedView);
    wrapper.roktEmbeddedView.frame = CGRectMake(0, 0, 330, 415);
    wrapper.frame = CGRectMake(0, 0, 390, 415);
    [wrapper layoutIfNeeded];
    XCTAssertEqualWithAccuracy(wrapper.roktEmbeddedView.frame.size.height, 415, 0.5);
    XCTAssertEqualWithAccuracy(wrapper.roktEmbeddedView.frame.size.width, 390, 0.5);
    wrapper.roktEmbeddedView.frame = CGRectMake(0, 0, 390, 533);
    wrapper.frame = CGRectMake(0, 0, 390, 533);
    [wrapper layoutIfNeeded];
    XCTAssertEqualWithAccuracy(wrapper.roktEmbeddedView.frame.size.height, 533, 0.5);
    [wrapper invalidate];
}

- (void)testSelectionWaitsForEveryNameWhateverTheValue
{
    // A positive value was a view tag, which skipped the wait. Every key is a name now.
    RoktSelectionProbe *module = [RoktSelectionProbe new];
    [module selectPlacementsWithIdentifier:@"page" attributes:@{} placeholders:@{@"TestLocation1": @101} config:nil];
    XCTestExpectation *drained = [self expectationWithDescription:@"main queue drained"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [drained fulfill];
    });
    [self waitForExpectations:@[drained] timeout:1];
    XCTAssertEqual(module.resolutions, 0, @"Selection must wait for the named view to mount");
    [module invalidate];
}

- (void)testInvalidatingModuleCancelsQueuedSelection
{
    RoktSelectionProbe *module = [RoktSelectionProbe new];
    [module selectPlacementsWithIdentifier:@"page" attributes:@{} placeholders:@{} config:nil];
    [module invalidate];
    XCTestExpectation *drained = [self expectationWithDescription:@"main queue drained"];
    dispatch_async(dispatch_get_main_queue(), ^{ [drained fulfill]; });
    [self waitForExpectations:@[drained] timeout:1];
    XCTAssertEqual(module.resolutions, 0);
}

- (void)testConfiguredSelectionSubscribesThenPassesTheConfig
{
    // Events reach JavaScript through the view subscription; RNRoktSDK passes the SDK no onEvent.
    Method method = class_getClassMethod([RNRoktSDK class],
        @selector(selectPlacementsWithIdentifier:attributes:placements:config:));
    XCTAssertNotEqual(method, NULL);
    if (method == NULL) return;
    RoktSelectionProbe *module = [RoktSelectionProbe new];
    RoktConfig *config = [[[RoktConfigBuilder alloc] init] build];
    XCTestExpectation *selected = [self expectationWithDescription:@"configured selection"];
    IMP probe = imp_implementationWithBlock(^(id receiver, NSString *identifier, NSDictionary *attributes,
        NSDictionary *placements, NSObject *nativeConfig) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertEqual(nativeConfig, config);
        XCTAssertEqual(module.subscriptions, 1);
        [selected fulfill];
    });
    IMP original = method_setImplementation(method, probe);
    @try {
        [module selectPlacementsWithIdentifier:@"page" attributes:@{} placeholders:@{} config:config];
        XCTAssertEqual(module.resolutions, 0, @"Selection must be deferred beyond mounting");
        [self waitForExpectations:@[selected] timeout:1];
    } @finally {
        method_setImplementation(method, original);
        imp_removeBlock(probe);
        [module invalidate];
    }
}

@end
