platform :ios, '11.0'

target 'sariska-media-swift' do
	  use_frameworks!
    pod  'sariska-media-transport', :git => 'https://github.com/SariskaIO/sariska-ios-sdk-releases.git', tag:'1.1.1', :branch => 'master'

    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
        end
    end
end
