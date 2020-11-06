require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "rokt-sdk-react-native"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]
  #   todo change 
  s.homepage     = "test"
  s.summary      = "test"

  s.platforms    = { :ios => "9.0" }
#   todo change 
  s.source       = { :git => "https://github.com/danial-rokt/test.git", :tag => "#{s.version}" }

  
  s.source_files = "ios/**/*.*"
  

  s.dependency "React"
  s.dependency "Rokt-Widget"
end
