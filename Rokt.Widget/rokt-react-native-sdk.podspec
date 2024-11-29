require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "rokt-react-native-sdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]
  #   todo change 
  s.homepage     = "https://github.com/ROKT/rokt-sdk-react-native"
  s.summary      = "Rokt Mobile SDK to integrate ROKT Api into React Native iOS application"

  s.platforms    = { :ios => "10.0" }
#   todo change 
  s.source       = { :git => "https://github.com/ROKT/rokt-sdk-react-native", :tag => "#{s.version}" }

  
  s.source_files = "ios/**/*.{h,m}"
  

  s.dependency "React"
  s.dependency "Rokt-Widget", "~> 4.7.0-alpha.3"
end
