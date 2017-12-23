#
# Be sure to run `pod lib lint JPImageresizerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JPImageresizerView'
  s.version          = '0.1.1'
  s.summary          = '仿微信的裁剪图片功能的小框架'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
仿微信的裁剪图片功能的小框架，自适应裁剪区域的缩放，高度自定义设定，目前最多支持8个方向进行拖拽，以后会实现苹果的拖拽控制方向效果。
                       DESC

  s.homepage         = 'https://github.com/Rogue24/JPImageresizerView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZhouJianPing' => 'zhoujianping24@hotmail.com' }
  s.source           = { :git => 'https://github.com/Rogue24/JPImageresizerView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'JPImageresizerView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JPImageresizerView' => ['JPImageresizerView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
