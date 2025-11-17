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

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<RoktNativeWidgetComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _roktEmbeddedView = [[RoktEmbeddedView alloc] initWithFrame:self.bounds];
    _roktEmbeddedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_roktEmbeddedView];
    NSLog(@"[ROKT] iOS Fabric: RoktNativeWidgetComponentView initialized with frame: %@", NSStringFromCGRect(frame));
    NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView created and added to view hierarchy");
  }
  return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
  NSLog(@"[ROKT] iOS Fabric: willMoveToWindow called");
  NSLog(@"[ROKT] iOS Fabric: Current window: %@", self.window);
  NSLog(@"[ROKT] iOS Fabric: New window: %@", newWindow);
  NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView superview before removal: %@", self.roktEmbeddedView.superview);
  
  // Remove the embedded view from hierarchy when moving to a new window
  if (self.roktEmbeddedView && self.roktEmbeddedView.superview) {
    NSLog(@"[ROKT] iOS Fabric: Removing RoktEmbeddedView from superview");
    [self.roktEmbeddedView removeFromSuperview];
    NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView removed successfully");
  } else {
    NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView not in view hierarchy, skipping removal");
  }
  
  [super willMoveToWindow:newWindow];
}

- (void)didMoveToWindow
{
  [super didMoveToWindow];
  
  NSLog(@"[ROKT] iOS Fabric: didMoveToWindow called");
  NSLog(@"[ROKT] iOS Fabric: Current window: %@", self.window);
  NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView superview before adding: %@", self.roktEmbeddedView.superview);
  
  if (!self.window) {
    NSLog(@"[ROKT] iOS Fabric: No window available, RoktEmbeddedView not re-added");
    return;
  }
  
  if (!self.roktEmbeddedView) {
    NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView is nil");
    return;
  }
  
  if (self.roktEmbeddedView.superview) {
    NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView already has superview, skipping re-add");
    return;
  }
  
  // Re-add the embedded view to hierarchy after moving to new window
  NSLog(@"[ROKT] iOS Fabric: Adding RoktEmbeddedView back to view hierarchy");
  NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView frame: %@", NSStringFromCGRect(self.roktEmbeddedView.frame));
  NSLog(@"[ROKT] iOS Fabric: Self frame: %@", NSStringFromCGRect(self.frame));
  NSLog(@"[ROKT] iOS Fabric: Self bounds: %@", NSStringFromCGRect(self.bounds));
  
  self.roktEmbeddedView.frame = self.bounds;
  [self addSubview:self.roktEmbeddedView];
  NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView added successfully");
  NSLog(@"[ROKT] iOS Fabric: RoktEmbeddedView superview after adding: %@", self.roktEmbeddedView.superview);
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  // Check if the shared pointers are valid before dereferencing
  if (!oldProps || !props) {
    [super updateProps:props oldProps:oldProps];
    return;
  }
  
  const auto &oldViewProps = *std::static_pointer_cast<const RoktNativeWidgetProps>(oldProps);
  const auto &newViewProps = *std::static_pointer_cast<const RoktNativeWidgetProps>(props);

  // Handle placeholderName prop
  if (oldViewProps.placeholderName != newViewProps.placeholderName) {
    _placeholderName = [NSString stringWithUTF8String:newViewProps.placeholderName.c_str()];
    NSLog(@"[ROKT] iOS Fabric: RoktNativeWidgetComponentView placeholder name set to: %@", _placeholderName);
  }

  [super updateProps:props oldProps:oldProps];
}

// Export function for codegen compatibility
// This may be referenced by generated code even though we use the class name in package.json
extern "C" Class<RCTComponentViewProtocol> RoktNativeWidgetCls(void) {
  return RoktNativeWidgetComponentView.class;
}

@end
#endif // RCT_NEW_ARCH_ENABLED
