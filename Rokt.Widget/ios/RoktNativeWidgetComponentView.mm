//
//  RoktNativeWidgetFabricViewManager.m
//  rokt-sdk-react-native
//
//  Copyright 2025 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

#ifdef RCT_NEW_ARCH_ENABLED
#import <SafariServices/SafariServices.h>
#import "RoktNativeWidgetComponentView.h"
#import "RoktPlaceholderRegistry.h"
#import <React/RCTConversions.h>

#import "RNRoktSwift.h"
#import <React/renderer/components/RNRoktWidgetSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNRoktWidgetSpec/Props.h>
#import <React/renderer/components/RNRoktWidgetSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface RoktNativeWidgetComponentView () <RCTRoktNativeWidgetViewProtocol>
@property (nonatomic, nullable) UIView *roktEmbeddedView;
@property (nonatomic, nullable) NSString *placeholderName;
@end

@implementation RoktNativeWidgetComponentView {
    UIView * _view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<RoktNativeWidgetComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self installEmbeddedView];
    NSLog(@"[ROKT] iOS Fabric: RoktFabricWrapperView initialized");
  }
  return self;
}

- (void)installEmbeddedView
{
  // Zero height: a recycled wrapper still has the previous mount's size.
  _roktEmbeddedView = [RNRoktViews makeEmbeddedViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0)];
  // Width only: the Rokt SDK owns the height (updateEmbeddedSize sets it before JS
  // resizes this view), so flexible height would re-apply that delta once React Native
  // caught up, doubling the embedded view and centring the layout below blank space.
  _roktEmbeddedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self addSubview:_roktEmbeddedView];
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &newProps = *std::static_pointer_cast<const RoktNativeWidgetProps>(props);
  NSString *name = RCTNSStringFromStringNilIfEmpty(newProps.placeholderName);
  if (name != _placeholderName && ![name isEqualToString:_placeholderName]) {
    _placeholderName = name;
    [RoktPlaceholderRegistry registerView:_roktEmbeddedView name:name];
  }
  [super updateProps:props oldProps:oldProps];
}

- (void)prepareForRecycle
{
  [RoktPlaceholderRegistry unregisterView:_roktEmbeddedView];
  _placeholderName = nil;
  // Fabric reuses this wrapper for later mounts; the next one must not inherit the
  // placement the SDK rendered into the current embedded view.
  [_roktEmbeddedView removeFromSuperview];
  [self installEmbeddedView];
  [super prepareForRecycle];
}

// Export function for codegen compatibility
// This may be referenced by generated code even though we use the class name in package.json
extern "C" Class<RCTComponentViewProtocol> RoktNativeWidgetCls(void) {
  return RoktNativeWidgetComponentView.class;
}

@end
#endif // RCT_NEW_ARCH_ENABLED
