Pod::Spec.new do |s|
  s.name             = 'YesidFaceEnrollment'
  s.version          = '0.1.0'
  s.summary      = 'Facial enrollment library with liveness detection.'
  s.description  = 'YesidFaceEnrollment provides a simple and secure way to enroll a user\'s face by capturing nine angles, including top, top right, right, bottom right, bottom, left, top left, bottom left, using a liveness detection mechanism. This library can be integrated into any iOS app, allowing users to easily enroll their faces and access secure features of the app.'


  s.homepage         = 'https://github.com/IDTech-Tanzania/YesidFaceEnrollment'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Emmanuel Mtera' => 'emtera@yesid.io' }
  s.source = { :git => 'https://github.com/IDTech-Tanzania/YesidFaceEnrollment.git', :tag => s.version.to_s}


  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.0']

  s.source_files = 'YesidFaceEnrollment/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YesidFaceEnrollment' => ['YesidFaceEnrollment/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
