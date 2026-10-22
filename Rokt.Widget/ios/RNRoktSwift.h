//
//  RNRoktSwift.h
//  rokt-react-native-sdk
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

// Implemented in Swift (Swift/*.swift). Declared by hand instead of importing the generated -Swift.h
// header: when the SDK is a Swift package, the Swift code can be a separate target, and Objective-C++
// files cannot reach another target's generated header without C++ modules. Only Foundation and
// UIKit types appear here, so these files never need the Rokt SDK's headers. Keep each declaration in
// step with its @objc name; RNRoktSwiftTests checks them.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNRoktSDK : NSObject
+ (void)setReactNativeFrameworkType;
+ (void)initializeWithTagId:(NSString *)tagId;
+ (void)subscribeToGlobalEvents:(void (^)(NSObject *event))handler;
+ (void)subscribeToEventsWithIdentifier:(NSString *)identifier handler:(void (^)(NSObject *event))handler;
+ (void)selectPlacementsWithIdentifier:(NSString *)identifier
                            attributes:(NSDictionary<NSString *, NSString *> *)attributes
                            placements:(NSDictionary<NSString *, UIView *> *)placements
                                config:(nullable NSObject *)config;
+ (void)selectShoppableAdsWithIdentifier:(NSString *)identifier
                              attributes:(NSDictionary<NSString *, NSString *> *)attributes
                                  config:(nullable NSObject *)config;
+ (void)setStageEnvironment:(BOOL)stage;
+ (void)setSessionId:(NSString *)sessionId;
+ (nullable NSString *)sessionId;
+ (void)setCustomBaseURL:(NSURL *)url;
+ (void)setBuiltInPayPalRedirectURLScheme:(nullable NSString *)scheme;
+ (void)handleURLCallback:(NSURL *)url;
+ (void)purchaseFinalizedWithIdentifier:(NSString *)identifier catalogItemId:(NSString *)catalogItemId success:(BOOL)success;
@end

@interface RNRoktConfigFactory : NSObject
+ (NSObject *)configWithColorMode:(nullable NSString *)colorMode
                            cache:(BOOL)cache
                    cacheDuration:(nullable NSNumber *)cacheDuration
                  cacheAttributes:(nullable NSDictionary<NSString *, NSString *> *)cacheAttributes;
@end

@interface RNRoktEventMapper : NSObject
+ (NSDictionary<NSString *, id> *)payloadForEvent:(NSObject *)event viewName:(nullable NSString *)viewName;
+ (nullable NSNumber *)embeddedHeightForEvent:(NSObject *)event;
@end

@interface RNRoktViews : NSObject
+ (UIView *)makeEmbeddedViewWithFrame:(CGRect)frame;
+ (BOOL)isEmbeddedView:(nullable UIView *)view;
@end

NS_ASSUME_NONNULL_END
