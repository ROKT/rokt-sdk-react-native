import UIKit
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider
import Rokt_Widget
// Uncomment when RoktPaymentExtension is published:
// import RoktPaymentExtension

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  var reactNativeDelegate: ReactNativeDelegate?
  var reactNativeFactory: RCTReactNativeFactory?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let delegate = ReactNativeDelegate()
    let factory = RCTReactNativeFactory(delegate: delegate)
    delegate.dependencyProvider = RCTAppDependencyProvider()

    reactNativeDelegate = delegate
    reactNativeFactory = factory

    window = UIWindow(frame: UIScreen.main.bounds)

    factory.startReactNative(
      withModuleName: "RoktSampleApp",
      in: window,
      launchOptions: launchOptions
    )

    // Register payment extension for shoppable ads (uncomment when RoktPaymentExtension is published):
    // let stripeExtension = RoktStripePaymentExtension(applePayMerchantId: "merchant.com.rokt.sample")
    // Rokt.registerPaymentExtension(stripeExtension, config: ["stripeKey": "pk_test_placeholder"])

    return true
  }
}

class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    self.bundleURL()
  }

  override func bundleURL() -> URL? {
#if DEBUG
    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}
