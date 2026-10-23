// swift-tools-version: 6.0
// Experimental: for React Native's Swift Package Manager mode (tested with React Native 0.87.1); not
// for production use. CocoaPods apps do not use this file. ReactNative and React-GeneratedCode are the
// local packages React Native's autolinker generates for each app, at these paths relative to where it
// places this package, as other React Native libraries reference them.

import PackageDescription

let package = Package(
    name: "RoktReactNativeSdk",
    // React Native's autolinker requires iOS 15; the Rokt iOS SDK declares the same.
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "RoktReactNativeSdk", targets: ["RoktReactNativeSdk"])
    ],
    dependencies: [
        .package(name: "ReactNative", path: "../../../../xcframeworks"),
        .package(name: "React-GeneratedCode", path: "../../../ios"),
        // Same URLs as the mParticle Rokt kit uses, so an app with both resolves one package identity.
        .package(url: "https://github.com/ROKT/rokt-sdk-ios", "5.3.0"..<"6.0.0"),
        .package(url: "https://github.com/ROKT/rokt-contracts-apple.git", "2.0.0"..<"3.0.0")
    ],
    targets: [
        // A separate target: Swift Package Manager cannot mix Swift and Objective-C++ in one target.
        .target(
            name: "RoktReactNativeSdkSwift",
            dependencies: [
                .product(name: "Rokt-Widget", package: "rokt-sdk-ios"),
                .product(name: "RoktContracts", package: "rokt-contracts-apple")
            ],
            path: "ios/Swift"
        ),
        .target(
            name: "RoktReactNativeSdk",
            dependencies: [
                "RoktReactNativeSdkSwift",
                .product(name: "ReactHeaders", package: "ReactNative"),
                .product(name: "ReactNativeHeaders", package: "ReactNative"),
                .product(name: "ReactNativeDependenciesHeaders", package: "ReactNative"),
                .product(name: "ReactAppHeaders", package: "React-GeneratedCode")
            ],
            path: ".",
            sources: [
                "ios/RNRoktSDKImports.h",
                "ios/RNRoktSwift.h",
                "ios/RNRoktWidget.h",
                "ios/RNRoktWidget.mm",
                "ios/RNRoktWidgetModuleProvider.mm",
                "ios/RoktEventManager.h",
                "ios/RoktEventManager.mm",
                "ios/RoktLegacyEmbeddedView.h",
                "ios/RoktNativeWidgetComponentView.h",
                "ios/RoktNativeWidgetComponentView.mm",
                "ios/RoktPlaceholderRegistry.h",
                "ios/RoktPlaceholderRegistry.m",
                "ios/RoktWidgetManager.m"
            ],
            publicHeadersPath: "ios",
            // Without RCT_NEW_ARCH_ENABLED the TurboModule and Fabric code compiles out, and the app
            // fails to find the RoktNativeWidget component.
            cSettings: [.define("RCT_NEW_ARCH_ENABLED", to: "1")],
            cxxSettings: [
                .define("RCT_NEW_ARCH_ENABLED", to: "1"),
                .define("DEBUG", .when(configuration: .debug)),
                .define("NDEBUG", .when(configuration: .release))
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics")
            ]
        )
    ],
    // Swift 5 mode, as the podspec builds the Swift layer.
    swiftLanguageModes: [.v5],
    cxxLanguageStandard: .cxx20
)
