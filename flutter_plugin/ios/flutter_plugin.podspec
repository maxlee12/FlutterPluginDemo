#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }

  # 手动添加的信息
  s.static_framework = true
  s.frameworks = ["QuartzCore", "SystemConfiguration","AVFoundation","CoreTelephony","AudioToolbox"] # 示例科大讯飞example需要的 iOS framework
  s.libraries = ["z","c++"]
  s.preserve_paths = 'Libs/*.framework' # 示例科大讯飞自己的framework
  s.vendored_frameworks = "**/*.framework" # 其他framework 文件
  s.resource = ['Resources/*/*.jet'] # 需要的Resources文件
end
