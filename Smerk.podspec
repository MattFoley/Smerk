Pod::Spec.new do |s|
  s.name             = "Smerk"
  s.version          = "0.0.1"
  s.summary          = "The open source fonts for Yangboz apps + Smerk categories."
  s.homepage         = "https://github.com/yangboz/Specs"
  s.license          = 'Code is MIT, then custom code licenses.'
  s.author           = { "Knight" => "youngwelle@gmail.com" }
  s.source           = { :git => "https://github.com/yangboz/Specs.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/smartkit'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*'

  s.frameworks = 'UIKit', 'CoreText'
  s.module_name = 'Yangboz_Smerk'
end