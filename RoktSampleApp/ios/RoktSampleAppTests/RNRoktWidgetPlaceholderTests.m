#import <XCTest/XCTest.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import "../../../Rokt.Widget/ios/RNRoktWidget.h"

// Implemented in RNRoktWidget.mm.
@interface RNRoktWidget (PlaceholderTests)
- (NSMutableDictionary *)resolvePlaceholders:(NSDictionary *)placeholders;
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
        if (strongSelf && level >= RCTLogLevelError) {
            strongSelf->_loggedErrorCount++;
            [strongSelf->_loggedErrors addObject:message ?: @""];
        }
    });
}

- (void)tearDown
{
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
    NSDictionary *resolved = [_rokt resolvePlaceholders:@{@"Location1" : @999}];

    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 1, @"errors: %@", _loggedErrors);
}

- (void)testSkipsTagResolvingToUnexpectedViewClass
{
    _views[@101] = [[UIView alloc] init];

    NSDictionary *resolved = [_rokt resolvePlaceholders:@{@"Location1" : @101}];

    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 1, @"errors: %@", _loggedErrors);
}

- (void)testSkipsNonNumericTagsWithoutThrowing
{
    NSDictionary *resolved =
        [_rokt resolvePlaceholders:@{@"Location1" : [NSNull null], @"Location2" : @"101"}];

    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 2, @"errors: %@", _loggedErrors);
    XCTAssertTrue([_loggedErrors.firstObject hasPrefix:@"Invalid react tag"],
                  @"errors: %@", _loggedErrors);
}

- (void)testEmptyPlaceholdersResolveToEmptyDictionary
{
    NSDictionary *resolved = [_rokt resolvePlaceholders:@{}];

    XCTAssertEqual(resolved.count, 0u);
    XCTAssertEqual(_loggedErrorCount, 0, @"errors: %@", _loggedErrors);
}

@end
