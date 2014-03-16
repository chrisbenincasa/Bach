Pod::Spec.new do |spec|
  spec.name     = 'Bach'
  spec.version  = '0.9.0'
  spec.license  = :type => 'MIT'
  spec.homepage = 'https://github.com/chrisbenincasa/Bach'
  spec.authors  = 'Christian Benincasa' => 'chrisbenincasa@gmail.com'
  spec.summary  = 'Simple and Fast Objective-C Audio Engine'
  spec.source   = :git => 'https://github.com/CocoaPods/Specs.git', :submodules => true
  spec.source_files = 'Bach/*.{h,m}'
  spec.osx.deployment_target = '10.9'
  spec.requires_arc = true
  spec.frameworks = 'AVFoundation', 'AudioToolbox', 'AudioUnit'
end
