Pod::Spec.new do |s|
  s.name             = 'device_security_kit'
  s.version          = '1.0.3'
  s.summary          = 'A comprehensive device security toolkit for Flutter'
  s.description      = <<-DESC
A comprehensive device security toolkit for Flutter with root/jailbreak detection, debugger detection, emulator detection, and more.
                       DESC
  s.homepage         = 'https://github.com/h1s97x/DeviceSecurityKit'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'H1S97X' => 'Yang1297656998@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.12'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
