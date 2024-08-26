amplitude_version = "0.0.1" # Version is managed automatically by semantic-release, please don't change it manually

Pod::Spec.new do |s|
  s.name                   = "AmplitudeSegmentSessionReplayPlugin"
  s.version                = amplitude_version
  s.summary                = "Amplitude Segment Session Replay Plugin"
  s.homepage               = "https://amplitude.com"
  s.license                = { :type => "MIT" }
  s.author                 = { "Amplitude" => "dev@amplitude.com" }
  s.source                 = { :git => "https://github.com/amplitude/AmplitudeSessionReplay-iOS.git", :tag => "v#{s.version}" }

  s.swift_version = '5.7'

  s.ios.deployment_target  = '13.0'
  s.source_files = 'Sources/AmplitudeSegmentSessionReplayPlugin/**/*'
  s.dependency 'AnalyticsSwift', '~> 1.9'
  s.dependency 'AmplitudeSessionReplay', '0.0.2'
end
