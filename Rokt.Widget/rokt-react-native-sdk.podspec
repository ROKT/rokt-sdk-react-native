require "json"
require_relative "ios/rokt_spm"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name         = "rokt-react-native-sdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]
  s.homepage     = "https://github.com/ROKT/rokt-sdk-react-native"
  s.summary      = "Rokt Mobile SDK to integrate ROKT Api into React Native iOS application"

  s.platforms = { :ios => "15.0" }
  s.source       = { :git => "https://github.com/ROKT/rokt-sdk-react-native", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift,mm}"

  # Use install_modules_dependencies helper to install the dependencies if React Native version >=0.71.0.
  # See https://github.com/facebook/react-native/blob/febf6b7f33fdb4904669f99d795eba4c0f95d7bf/scripts/cocoapods/new_architecture.rb#L79.
  if respond_to?(:install_modules_dependencies, true)
    install_modules_dependencies(s)
  else
    # Manual fallback for older React Native versions
    s.dependency "React-Core"
    s.compiler_flags = folly_compiler_flags

    # Simplified configuration for older React Native versions
    s.pod_target_xcconfig = {
      "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
      "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
      "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
    }

    # Only include essential dependencies for React Native 0.69.x
    s.dependency "RCT-Folly"
    s.dependency "RCTRequired"
    s.dependency "RCTTypeSafety"

    # Only include TurboModule support if New Architecture is enabled
    if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
      s.dependency "ReactCommon/turbomodule/core"
      s.compiler_flags << " -DRCT_NEW_ARCH_ENABLED=1"
    end
  end

  # Swift Package Manager mode is the default: ios/rokt_spm.rb links the Rokt iOS SDK into the app
  # target on each `pod install`. `$RNRoktDisableSPM = true` at the top of the Podfile takes it from
  # CocoaPods instead.
  if RNRoktSPM.enabled?
    # The app target links the Rokt iOS SDK as a Swift package. This pod only compiles against its
    # generated headers and never links it, so it is a static framework even under
    # `use_frameworks! :linkage => :dynamic`.
    s.static_framework = true
    # Xcode writes the packages' generated Objective-C headers here, for build and archive alike.
    maps = "$(OBJROOT)/GeneratedModuleMaps-$(PLATFORM_NAME)"
    xcconfig = s.attributes_hash["pod_target_xcconfig"] || {}
    s.pod_target_xcconfig = xcconfig.merge(
      "HEADER_SEARCH_PATHS" => "#{xcconfig["HEADER_SEARCH_PATHS"]} \"#{maps}\"".strip
    )
    # Declaring the headers as inputs orders this phase, and so this pod's compile, after the
    # packages that generate them.
    s.script_phase = {
      :name => "[Rokt] Check the Rokt Swift package headers",
      :execution_position => :before_compile,
      :input_files => ["${OBJROOT}/GeneratedModuleMaps-${PLATFORM_NAME}/RoktContracts-Swift.h",
                       "${OBJROOT}/GeneratedModuleMaps-${PLATFORM_NAME}/Rokt_Widget-Swift.h"],
      :output_files => ["${DERIVED_FILE_DIR}/rokt-spm-headers.stamp"],
      :script => <<~'SH'
        set -eu
        for header in RoktContracts-Swift.h Rokt_Widget-Swift.h; do
          if [ ! -f "${OBJROOT}/GeneratedModuleMaps-${PLATFORM_NAME}/${header}" ]; then
            echo "error: [Rokt] Swift Package Manager mode is on, but the Rokt-Widget Swift package is not linked into the app target. Run pod install again, or set \$RNRoktDisableSPM = true at the top of the Podfile to take the SDK from CocoaPods."
            exit 1
          fi
        done
        mkdir -p "${DERIVED_FILE_DIR}"
        touch "${DERIVED_FILE_DIR}/rokt-spm-headers.stamp"
      SH
    }
  else
    s.dependency "Rokt-Widget", ">= 5.3.0", "< 6.0.0"
  end
end
