import UIKit
import React
import React_RCTAppDelegate
import React_RCTLinking
import ReactAppDependencyProvider
import Rokt_Widget
// Uncomment to enable Shoppable Ads payment extension:
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
    // let paymentExtension = RoktPaymentExtension(applePayMerchantId: "merchant.com.rokt.sample")
    // Rokt.registerPaymentExtension(paymentExtension, config: ["stripeKey": "pk_test_placeholder"])

    return true
  }

  // Forwards incoming deep links (e.g. the built-in PayPal redirect scheme
  // registered in Info.plist) to React Native's `Linking` module, so JS-side
  // listeners such as `Rokt.handleURLCallback` fire.
  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    RCTLinkingManager.application(app, open: url, options: options)
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
