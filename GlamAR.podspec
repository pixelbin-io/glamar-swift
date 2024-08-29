Pod::Spec.new do |s|
  s.name         = 'GlamAR'
  s.version      = '1.0.0'
  s.summary      = 'Enhance your web applications with advanced Augmented Reality (AR) features using the GlamAR SDK.'
  s.description  = <<-DESC
    The GlamAR SDK enables developers to effortlessly integrate advanced Augmented Reality (AR) capabilities into their web applications. Utilizing machine learning and deep learning models, GlamAR tracks facial features and expressions, overlaying them with realistic 2D and 3D graphics in real-time. Ideal for creating immersive experiences like virtual try-ons for makeup, eyewear, accessories, nails, and hair, the SDK includes all the necessary components to help you focus on visual design while it handles the complex AR processes.
  DESC
  s.homepage     = 'https://github.com/pixelbin-io/glamar-swift'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Author Name' => 'dipendrasharma@gofynd.com' }
  s.source       = { :git => 'https://github.com/pixelbin-io/glamar-swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'
  s.source_files  = 'Sources/**/*.{swift,h,m}'
  s.exclude_files = 'Example'
  s.swift_version = '5.8'

  s.dependency 'Alamofire', '~> 5.9.1'  # Alamofire dependency
end
