#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_platform_native_ui.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_platform_native_ui'
  s.version          = '0.0.1'
  s.summary          = 'Native platform UI components for Flutter.'
  s.description      = <<-DESC
A Flutter API backed by a real UIKit tab bar on iOS.
                       DESC
  s.homepage         = 'https://github.com/KRMiiz/flutter_platform_native_ui'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KRMiiz' => 'https://github.com/KRMiiz' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_platform_native_ui/Sources/flutter_platform_native_ui/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'flutter_platform_native_ui_privacy' => ['flutter_platform_native_ui/Sources/flutter_platform_native_ui/PrivacyInfo.xcprivacy']}
end
