amplitude_version = "0.8.1" # Version is managed automatically by semantic-release, please don't change it manually

Pod::Spec.new do |s|
  s.name                   = "AmplitudeSessionReplay"
  s.version                = amplitude_version
  s.summary                = "Amplitude Session Replay SDK"
  s.homepage               = "https://amplitude.com"
  s.license                = { :type => "MIT" }
  s.author                 = { "Amplitude" => "dev@amplitude.com" }
  s.source                 = { :git => "https://github.com/amplitude/AmplitudeSessionReplay-iOS.git", :tag => "v#{s.version}" }

  s.swift_version = '5.7'

  s.ios.deployment_target  = '13.0'
  s.vendored_frameworks = "Frameworks/AmplitudeSessionReplay.xcframework"

  s.dependency 'AmplitudeCore', '>= 1.1.0', '< 2.0.0'
end
