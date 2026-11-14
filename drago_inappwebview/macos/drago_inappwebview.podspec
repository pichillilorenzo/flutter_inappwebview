#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint drago_inappwebview.podspec` to validate before publishing.
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
  s.source_files     = 'drago_inappwebview/Sources/drago_inappwebview/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.resource_bundles = {'drago_inappwebview_privacy' => ['drago_inappwebview/Sources/drago_inappwebview/Resources/PrivacyInfo.xcprivacy']}

  # swift-collections podspec doesn't declare macOS support, so we must use OrderedSet library
  # s.dependency 'swift-collections', '~>1.1.1'
  s.dependency 'OrderedSet', '~>6.0.3'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.swift_version = '5.0'
end
