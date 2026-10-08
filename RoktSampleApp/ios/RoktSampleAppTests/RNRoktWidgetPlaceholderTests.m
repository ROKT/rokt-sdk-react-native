#import <XCTest/XCTest.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <RoktContracts/RoktContracts-Swift.h>
#import <Rokt_Widget/Rokt_Widget-Swift.h>
#import <objc/runtime.h>
#import "../../../Rokt.Widget/ios/RoktPlaceholderRegistry.h"
#import "../../../Rokt.Widget/ios/RNRoktWidget.h"

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
    RCTViewRegistry *_viewRegistry;
    NSMutableDictionary<NSNumber *, UIView *> *_views;
    NSInteger _loggedErrorCount;
    NSMutableArray<NSString *> *_loggedErrors;
    RCTLogFunction _originalLogFunction;
}

- (void)setUp
{
    [super setUp];
    _rokt = [RNRoktWidget new];
    _views = [NSMutableDictionary new];

    _viewRegistry = [RCTViewRegistry new];
    __weak __typeof__(self) weakSelf = self;
    [_viewRegistry setBridgelessComponentViewProvider:^UIView *(NSNumber *reactTag) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        return strongSelf ? strongSelf->_views[reactTag] : nil;
    }];
    ((id<RCTBridgeModule>)_rokt).viewRegistry_DEPRECATED = _viewRegistry;

    _loggedErrorCount = 0;
    _loggedErrors = [NSMutableArray new];
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
        }
    });
}

- (void)tearDown
{
    [RoktPlaceholderRegistry cancelAllWaits];
    RCTSetLogFunction(_originalLogFunction);
    _rokt = nil;
    _viewRegistry = nil;
    _views = nil;
    [super tearDown];
}

- (void)testModuleUsesMainQueue
{
    XCTAssertEqual(_rokt.methodQueue, dispatch_get_main_queue());
}

- (void)testModuleRegistryResolvesMountedViews
{
    UIView *mountedView = [[UIView alloc] init];
    _views[@101] = mountedView;

    id<RCTBridgeModule> module = (id<RCTBridgeModule>)_rokt;
    XCTAssertNotNil(module.viewRegistry_DEPRECATED);
    XCTAssertEqualObjects([module.viewRegistry_DEPRECATED viewForReactTag:@101], mountedView);
    XCTAssertNil([module.viewRegistry_DEPRECATED viewForReactTag:@999]);
}

- (void)testSkipsTagThatIsNotMounted
{
    NSDictionary *resolved = [_rokt resolvePlaceholders:@{@"TestLocation1" : @999}];

    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 1, @"errors: %@", _loggedErrors);
}

- (void)testSkipsTagResolvingToUnexpectedViewClass
{
    _views[@101] = [[UIView alloc] init];

    NSDictionary *resolved = [_rokt resolvePlaceholders:@{@"TestLocation1" : @101}];

    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 1, @"errors: %@", _loggedErrors);
}

- (void)testSkipsNonNumericTagsWithoutThrowing
{
    NSDictionary *resolved =
        [_rokt resolvePlaceholders:@{@"TestLocation1" : [NSNull null], @"TestLocation2" : @"101"}];

    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 2, @"errors: %@", _loggedErrors);
    XCTAssertTrue([_loggedErrors.firstObject hasPrefix:@"Cannot resolve placeholder"],
                  @"errors: %@", _loggedErrors);
}

- (void)testEmptyPlaceholdersResolveToEmptyDictionary
{
    NSDictionary *resolved = [_rokt resolvePlaceholders:@{}];

    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 0, @"errors: %@", _loggedErrors);
}


- (void)testNameResolutionAndPositiveTagPrecedence
{
    RoktEmbeddedView *named = [RoktEmbeddedView new];
    RoktEmbeddedView *tagged = [RoktEmbeddedView new];
    [RoktPlaceholderRegistry registerView:named name:@"TestLocation1"];
    _views[@101] = tagged;
    XCTAssertEqual([_rokt resolvePlaceholders:@{@"TestLocation1": @0}][@"TestLocation1"], named);
    XCTAssertEqual([_rokt resolvePlaceholders:@{@"TestLocation1": @101}][@"TestLocation1"], tagged);
    XCTAssertEqual([_rokt resolvePlaceholders:@{@"TestLocation1": @999}][@"TestLocation1"], named);
    [RoktPlaceholderRegistry unregisterView:named];
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
    // React Native sets its architecture flag on C++ compilation, not this Objective-C target.
    XCTSkipIf(NSClassFromString(@"RoktNativeWidgetComponentView") != Nil,
              @"Paper lifecycle is verified in the Legacy Architecture build");
    RoktEmbeddedView *view = [RoktEmbeddedView new];
    [RoktPlaceholderRegistry registerView:view name:@"TestLocation1"];
    XCTAssertTrue([view conformsToProtocol:@protocol(RCTInvalidating)]);
    [(id<RCTInvalidating>)view invalidate];
    XCTAssertNil([RoktPlaceholderRegistry viewForName:@"TestLocation1"]);
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

- (void)testConfiguredSelectionUsesOnlyTheViewEventSubscription
{
    Method method = class_getClassMethod([Rokt class],
        @selector(selectPlacementsWithIdentifier:attributes:placements:config:placementOptions:onEvent:));
    XCTAssertNotEqual(method, NULL);
    if (method == NULL) return;
    RoktSelectionProbe *module = [RoktSelectionProbe new];
    RoktConfig *config = [[[RoktConfigBuilder alloc] init] build];
    XCTestExpectation *selected = [self expectationWithDescription:@"configured selection"];
    IMP probe = imp_implementationWithBlock(^(id receiver, NSString *identifier, NSDictionary *attributes,
        NSDictionary *placements, RoktConfig *nativeConfig, id options, id onEvent) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertEqual(nativeConfig, config);
        XCTAssertEqual(module.subscriptions, 1);
        XCTAssertNil(onEvent, @"Forwarding onEvent as well as the view subscription duplicates callbacks");
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
