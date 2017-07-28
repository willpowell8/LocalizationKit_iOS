#
# Be sure to run `pod lib lint LocalizationKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LocalizationKit'
  s.version          = '1.2.0'
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
  s.osx.deployment_target = '10.10'
  s.source_files = 'LocalizationKit/Classes/**/*'

  s.dependency 'Socket.IO-Client-Swift', '~>8.3.3'

  s.resource_bundles = {
    'LocalizationKit' => ['LocalizationKit/Assets/*.{storyboard,xib}']
  }
end
