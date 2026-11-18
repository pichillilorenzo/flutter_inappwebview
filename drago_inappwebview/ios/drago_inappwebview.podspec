#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutterplugintest.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'drago_inappwebview'
  s.version          = '7.0.0'
  s.summary          = 'Inline webview, headless webview and in-app browser for Flutter.'
  s.description      = <<-DESC
Inline webview, headless webview and in-app browser for Flutter (fork of flutter_inappwebview).
                       DESC
  s.homepage         = 'https://github.com/selvam920/drago_inappwebview'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'drago_inappwebview contributors'
  s.source           = { :path => '.' }
  s.source_files = 'drago_inappwebview/Sources/drago_inappwebview/**/*.swift'
  s.resources = 'drago_inappwebview/Sources/drago_inappwebview/Resources/**/*.storyboard'
  s.dependency 'Flutter'
  s.resource_bundles = {'drago_inappwebview_privacy' => ['drago_inappwebview/Sources/drago_inappwebview/Resources/PrivacyInfo.xcprivacy']}

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.libraries = 'swiftCoreGraphics'
  
  s.dependency 'swift-collections', '~>1.1.1'

  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }

  s.swift_version = '5.0'

  s.platforms = { :ios => '12.0' }

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.platform = :ios, '12.0'
  end
end
