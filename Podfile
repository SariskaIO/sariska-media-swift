# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Sariska-Demo-iOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Sariska-Demo-iOS
#	pod 'sariska-media-transport', :git => 'https://github.com/SariskaIO/sariska-ios-sdk-#releases.git', :branch => 'workingios'

	pod 'sariska-media-transport', :path => '/Users/dipaksisodiya/Desktop/sariska/sdks/sariska-ios-sdk-releases'
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
        end
    end
    
    pod 'SwiftyJSON'

	pod 'Alamofire', '~> 5.7'

end
