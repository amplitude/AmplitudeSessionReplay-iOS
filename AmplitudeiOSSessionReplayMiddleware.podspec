amplitude_version = "0.8.3" # Version is managed automatically by semantic-release, please don't change it manually

Pod::Spec.new do |s|
  s.name                   = "AmplitudeiOSSessionReplayMiddleware"
  s.version                = amplitude_version
  s.summary                = "Amplitude iOS Session Replay Middleware"
  s.homepage               = "https://amplitude.com"
  s.license                = { :type => "MIT" }
  s.author                 = { "Amplitude" => "dev@amplitude.com" }
  s.source                 = { :git => "https://github.com/amplitude/AmplitudeSessionReplay-iOS.git", :tag => "v#{s.version}" }
    
  s.swift_version = '5.7'

  s.ios.deployment_target  = '13.0'
  s.source_files = 'Sources/AmplitudeiOSSessionReplayMiddleware/**/*'
  
  s.dependency 'Amplitude', '~> 8.22'
  s.dependency 'AmplitudeSessionReplay', amplitude_version
end
