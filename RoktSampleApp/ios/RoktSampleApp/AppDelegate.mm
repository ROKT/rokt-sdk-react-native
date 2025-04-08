#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"RoktSampleApp";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [self bundleURL];
}

- (NSURL *)bundleURL
{
  #if DEBUG
  #ifdef IS_TESTING // Check for the macro defined in test target settings
  // Running tests, load pre-compiled bundle
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
  #else
  // Not running tests (normal Debug build), load from Metro
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
  #endif
  #else // Release build
      return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
  #endif
}

- (BOOL)bridgelessEnabled
{
 return NO;
}

@end
