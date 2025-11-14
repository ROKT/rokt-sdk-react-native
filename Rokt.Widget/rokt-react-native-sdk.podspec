require "json"

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

  s.platforms = { :ios => "10.0" }
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

  s.dependency "Rokt-Widget", "~> 4.14.3"
end
