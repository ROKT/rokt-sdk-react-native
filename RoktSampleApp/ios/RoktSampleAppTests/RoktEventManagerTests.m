#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "../../../Rokt.Widget/ios/RNRoktSDKImports.h"
#import "../../../Rokt.Widget/ios/RoktEventManager.h"

/**
 * Pins the payload JavaScript receives for each Rokt SDK event, as the RoktEvents and
 * WidgetHeightChanges events that RoktEventManager emits.
 */
@interface RoktEventManagerTests : XCTestCase
@end

@implementation RoktEventManagerTests {
    RoktEventManager *_manager;
    NSMutableArray<NSDictionary *> *_sent;
    Method _method;
    IMP _original;
    IMP _probe;
}

- (void)setUp
{
    [super setUp];
    _manager = [RoktEventManager allocWithZone:nil];
    _sent = [NSMutableArray new];
    // Capture what would go to JavaScript; there is no bridge in a unit test.
    _method = class_getInstanceMethod([RoktEventManager class], @selector(sendEventWithName:body:));
    NSMutableArray *sent = _sent;
    _probe = imp_implementationWithBlock(^(__unused id receiver, NSString *name, id body) {
        [sent addObject:@{@"name" : name, @"body" : body ?: [NSNull null]}];
    });
    _original = method_setImplementation(_method, _probe);
    [_manager startObserving];
}

- (void)tearDown
{
    [_manager stopObserving];
    method_setImplementation(_method, _original);
    imp_removeBlock(_probe);
    [super tearDown];
}

- (NSDictionary *)payloadFor:(id)event identifier:(NSString *)identifier
{
    [_sent removeAllObjects];
    [_manager onRoktEvents:event identifier:identifier];
    XCTAssertEqualObjects(_sent.lastObject[@"name"], @"RoktEvents");
    return _sent.lastObject[@"body"];
}

- (void)testInitCompleteReportsItsStatusWithoutAViewName
{
    XCTAssertEqualObjects([self payloadFor:[[RoktInitComplete alloc] initWithSuccess:YES] identifier:nil],
                          (@{@"event" : @"InitComplete", @"status" : @"true"}));
    XCTAssertEqualObjects([self payloadFor:[[RoktInitComplete alloc] initWithSuccess:NO] identifier:nil],
                          (@{@"event" : @"InitComplete", @"status" : @"false"}));
}

- (void)testLoadingIndicatorsCarryOnlyTheViewName
{
    XCTAssertEqualObjects([self payloadFor:[RoktShowLoadingIndicator new] identifier:@"page"],
                          (@{@"event" : @"ShowLoadingIndicator", @"viewName" : @"page"}));
    XCTAssertEqualObjects([self payloadFor:[RoktHideLoadingIndicator new] identifier:@"page"],
                          (@{@"event" : @"HideLoadingIndicator", @"viewName" : @"page"}));
}

- (void)testPlacementEventsCarryThePlacementId
{
    NSDictionary<NSString *, id> *events = @{
        @"PlacementReady" : [[RoktPlacementReady alloc] initWithIdentifier:@"p1"],
        @"PlacementInteractive" : [[RoktPlacementInteractive alloc] initWithIdentifier:@"p1"],
        @"OfferEngagement" : [[RoktOfferEngagement alloc] initWithIdentifier:@"p1"],
        @"PositiveEngagement" : [[RoktPositiveEngagement alloc] initWithIdentifier:@"p1"],
        @"PlacementClosed" : [[RoktPlacementClosed alloc] initWithIdentifier:@"p1"],
        @"PlacementCompleted" : [[RoktPlacementCompleted alloc] initWithIdentifier:@"p1"],
        @"PlacementFailure" : [[RoktPlacementFailure alloc] initWithIdentifier:@"p1"],
    };
    for (NSString *name in events) {
        XCTAssertEqualObjects([self payloadFor:events[name] identifier:@"page"],
                              (@{@"event" : name, @"viewName" : @"page", @"placementId" : @"p1"}), @"%@", name);
    }
}

- (void)testOpenUrlCarriesTheUrl
{
    id event = [[RoktOpenUrl alloc] initWithIdentifier:@"p1" url:@"https://example.com"];
    XCTAssertEqualObjects([self payloadFor:event identifier:@"page"],
                          (@{@"event" : @"OpenUrl", @"viewName" : @"page", @"placementId" : @"p1",
                             @"url" : @"https://example.com"}));
}

- (void)testEmbeddedSizeChangedAlsoReportsTheHeight
{
    id event = [[RoktEmbeddedSizeChanged alloc] initWithIdentifier:@"p1" updatedHeight:120];
    XCTAssertEqualObjects([self payloadFor:event identifier:@"page"],
                          (@{@"event" : @"EmbeddedSizeChanged", @"viewName" : @"page", @"placementId" : @"p1"}));
    XCTAssertEqual(_sent.count, 2u);
    XCTAssertEqualObjects(_sent.firstObject,
                          (@{@"name" : @"WidgetHeightChanges",
                             @"body" : @{@"height" : @120, @"selectedPlacement" : @"p1"}}));
}

- (void)testCartItemInstantPurchaseCarriesEveryField
{
    id event = [[RoktCartItemInstantPurchase alloc] initWithIdentifier:@"p1"
                                                                  name:@"Item"
                                                            cartItemId:@"cart1"
                                                         catalogItemId:@"cat1"
                                                              currency:@"USD"
                                                           description:@"An item"
                                                       linkedProductId:@"linked1"
                                                          providerData:@"data"
                                                              quantity:[NSDecimalNumber decimalNumberWithString:@"2"]
                                                            totalPrice:[NSDecimalNumber decimalNumberWithString:@"20.5"]
                                                             unitPrice:[NSDecimalNumber decimalNumberWithString:@"10.25"]];
    XCTAssertEqualObjects([self payloadFor:event identifier:@"page"], (@{
                              @"event" : @"CartItemInstantPurchase",
                              @"viewName" : @"page",
                              @"placementId" : @"p1",
                              @"cartItemId" : @"cart1",
                              @"catalogItemId" : @"cat1",
                              @"currency" : @"USD",
                              @"description" : @"An item",
                              @"linkedProductId" : @"linked1",
                              @"providerData" : @"data",
                              @"quantity" : [NSDecimalNumber decimalNumberWithString:@"2"],
                              @"totalPrice" : [NSDecimalNumber decimalNumberWithString:@"20.5"],
                              @"unitPrice" : [NSDecimalNumber decimalNumberWithString:@"10.25"],
                          }));
}

- (void)testCartItemInstantPurchaseLeavesOutMissingOptionalFields
{
    id event = [[RoktCartItemInstantPurchase alloc] initWithIdentifier:@"p1"
                                                                  name:nil
                                                            cartItemId:@"cart1"
                                                         catalogItemId:@"cat1"
                                                              currency:@"USD"
                                                           description:@"An item"
                                                       linkedProductId:nil
                                                          providerData:@"data"
                                                              quantity:nil
                                                            totalPrice:nil
                                                             unitPrice:nil];
    XCTAssertEqualObjects([self payloadFor:event identifier:@"page"], (@{
                              @"event" : @"CartItemInstantPurchase",
                              @"viewName" : @"page",
                              @"placementId" : @"p1",
                              @"cartItemId" : @"cart1",
                              @"catalogItemId" : @"cat1",
                              @"currency" : @"USD",
                              @"description" : @"An item",
                              @"providerData" : @"data",
                          }));
}

- (void)testOtherPurchaseEvents
{
    XCTAssertEqualObjects(
        [self payloadFor:[[RoktCartItemInstantPurchaseInitiated alloc] initWithIdentifier:@"p1" catalogItemId:@"cat1" cartItemId:@"cart1"]
              identifier:@"page"],
        (@{@"event" : @"CartItemInstantPurchaseInitiated", @"viewName" : @"page", @"placementId" : @"p1",
           @"catalogItemId" : @"cat1", @"cartItemId" : @"cart1"}));
    XCTAssertEqualObjects(
        [self payloadFor:[[RoktCartItemInstantPurchaseFailure alloc] initWithIdentifier:@"p1" catalogItemId:@"cat1" cartItemId:@"cart1" error:@"declined"]
              identifier:@"page"],
        (@{@"event" : @"CartItemInstantPurchaseFailure", @"viewName" : @"page", @"placementId" : @"p1",
           @"catalogItemId" : @"cat1", @"error" : @"declined"}));
    XCTAssertEqualObjects(
        [self payloadFor:[[RoktCartItemDevicePay alloc] initWithIdentifier:@"p1" catalogItemId:@"cat1" cartItemId:@"cart1" paymentProvider:@"ApplePay"]
              identifier:@"page"],
        (@{@"event" : @"CartItemDevicePay", @"viewName" : @"page", @"placementId" : @"p1",
           @"paymentProvider" : @"ApplePay"}));
    XCTAssertEqualObjects([self payloadFor:[[RoktInstantPurchaseDismissal alloc] initWithIdentifier:@"p1"] identifier:@"page"],
                          (@{@"event" : @"InstantPurchaseDismissal", @"viewName" : @"page", @"placementId" : @"p1"}));
}

- (void)testAnEventWithoutAMappingSendsAnEmptyName
{
    id event = [[RoktFirstPositiveEngagement alloc] initWithIdentifier:@"p1" setFulfillmentAttributes:nil];
    XCTAssertEqualObjects([self payloadFor:event identifier:@"page"], (@{@"event" : @"", @"viewName" : @"page"}));
}

- (void)testSendsNothingWithoutListeners
{
    [_manager stopObserving];
    [_sent removeAllObjects];
    [_manager onRoktEvents:[RoktShowLoadingIndicator new] identifier:@"page"];
    XCTAssertEqual(_sent.count, 0u);
}

@end
