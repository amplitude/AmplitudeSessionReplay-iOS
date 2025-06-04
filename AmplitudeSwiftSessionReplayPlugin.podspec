amplitude_version = "0.4.5" # Version is managed automatically by semantic-release, please don't change it manually

Pod::Spec.new do |s|
  s.name                   = "AmplitudeSwiftSessionReplayPlugin"
  s.version                = amplitude_version
  s.summary                = "Amplitude Swift Session Replay Plugin"
  s.homepage               = "https://amplitude.com"
  s.license                = { :type => "MIT" }
  s.author                 = { "Amplitude" => "dev@amplitude.com" }
  s.source                 = { :git => "https://github.com/amplitude/AmplitudeSessionReplay-iOS.git", :tag => "v#{s.version}" }
    
  s.swift_version = '5.7'

  s.ios.deployment_target  = '13.0'
  s.source_files = 'Sources/AmplitudeSwiftSessionReplayPlugin/**/*'
  
  s.dependency 'AmplitudeSessionReplay', amplitude_version
end
