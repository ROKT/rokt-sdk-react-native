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

#import <Rokt_Widget/Rokt_Widget-Swift.h>
#import <React/renderer/components/RNRoktWidgetSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNRoktWidgetSpec/Props.h>
#import <React/renderer/components/RNRoktWidgetSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface RoktNativeWidgetComponentView () <RCTRoktNativeWidgetViewProtocol>
@property (nonatomic, nullable) RoktEmbeddedView *roktEmbeddedView;
@property (nonatomic, nullable) NSString *placeholderName;
@end

@implementation RoktNativeWidgetComponentView {
    UIView * _view;
}

// Static reference to hold the old placement across navigation
static RoktEmbeddedView *_staticRoktEmbeddedView = nil;

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<RoktNativeWidgetComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    // Reuse the static instance if it exists to simulate customer's issue
    if (_staticRoktEmbeddedView != nil) {
      _roktEmbeddedView = _staticRoktEmbeddedView;
      _roktEmbeddedView.frame = self.bounds;
      NSLog(@"[ROKT] iOS Fabric: Reusing existing static RoktEmbeddedView reference");
    } else {
      _roktEmbeddedView = [[RoktEmbeddedView alloc] initWithFrame:self.bounds];
      _staticRoktEmbeddedView = _roktEmbeddedView;
      NSLog(@"[ROKT] iOS Fabric: Created new RoktEmbeddedView and stored in static reference");
    }
    _roktEmbeddedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_roktEmbeddedView];
    NSLog(@"[ROKT] iOS Fabric: RoktNativeWidgetComponentView initialized with frame: %@", NSStringFromCGRect(frame));
    NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView created and added to view hierarchy");
  }
  return self;
}

- (void)didMoveToWindow
{
  [super didMoveToWindow];
  
  NSLog(@"[ROKT] iOS Fabric: didMoveToWindow called");
  NSLog(@"[ROKT] iOS Fabric: Current window: %@", self.window);
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{

  [super updateProps:props oldProps:oldProps];
}

// Export function for codegen compatibility
// This may be referenced by generated code even though we use the class name in package.json
extern "C" Class<RCTComponentViewProtocol> RoktNativeWidgetCls(void) {
  return RoktNativeWidgetComponentView.class;
}

@end
#endif // RCT_NEW_ARCH_ENABLED
