Pod::Spec.new do |s|
    s.name             = 'LocalizationKit'
    s.version          = '5.0.3'
    s.summary          = 'iOS Localization made easy. Localize texts and manage your translations in realtime to support multi lingual deployment.'

    s.description      = <<-DESC
    LocalizationKit is the easiest way to manage your texts and translations. It removes the need to recompile and redeploy an app or website to support new languages and texts. It uses a combination of sockets and rest to allow you to manage an app without resubmitting to the app store to make linguistic changes. Localize your app in one easy to use location.
    DESC

    s.homepage         = 'https://github.com/willpowell8/LocalizationKit_iOS'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Will Powell' => '' }
    s.source           = { :git => 'https://github.com/willpowell8/LocalizationKit_iOS.git', :tag => s.version }
    s.social_media_url = 'https://twitter.com/willpowelluk'

    s.ios.deployment_target = '8.0'
    s.osx.deployment_target = '10.11'
    s.tvos.deployment_target = '9.0'

    s.default_subspec = "Core"
    s.subspec "Core" do |ss|
        ss.source_files = 'Sources/Core/**/*'
        ss.ios.source_files = 'Sources/iOSClasses/**/*'
        ss.osx.source_files = 'Sources/OSXClasses/**/*'
        ss.framework  = "Foundation"
        ss.ios.framework  = 'UIKit'
    end

    s.swift_version = '5.0'

    s.dependency 'Socket.IO-Client-Swift', '~> 15.0.0'

    s.ios.resource_bundles = {
    'LocalizationKit' => ['Assets/ios/*.{storyboard,xib}']
    }
end
