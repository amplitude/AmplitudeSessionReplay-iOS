<p align="center">
  <a href="https://amplitude.com" target="_blank" align="center">
    <img src="https://static.amplitude.com/lightning/46c85bfd91905de8047f1ee65c7c93d6fa9ee6ea/static/media/amplitude-logo-with-text.4fb9e463.svg" width="280">
  </a>
  <br />
</p>


# AmplitudeSessionReplay-iOS

This is Amplitude's latest version of the Session Replay SDK for iOS.

## Integrations

AmplitudeSessionReplay integrates via plugin to your core analytics library. 

## SDK support

AmplitudeSessionReplay currently supports iOS 13.0 and above. *macOS support in Package.swift is only used for swift command line tools.*

## Instructions

To Start, import the library via your preferred package manager.

#### SPM
Use package `https://github.com/amplitude/AmplitudeSessionReplay-iOS.git`
Be careful to only add a single library to your target, based on your core analytics library as detailed below.

#### Cocoapods
Add `pod 'SUB_SPEC', :git => 'https://github.com/amplitude/AmplitudeSessionReplay-iOS.git'` to your Podfile, replacing SUB_SPEC with the appropriate subspec for your core analytics library as detailed below.

### Amplitude-Swift (Preferred)

1. Use target/subspec: `AmplitudeSwiftSessionReplayPlugin`

2. Import the framework:
```
import AmplitudeSwiftSessionReplayPlugin
```

3a. Add the plugin to your Amplitude instance:
```
amplitude.add(plugin: AmplitudeSwiftSessionReplayPlugin())
```

3b. Add the plugin to your Ampli instance (If using the Amplitude Wrapper) [Ampli Developer docs](https://amplitude.com/docs/sdks/ampli/migrate-to-ampli):
```
Ampli.instance.client.add(plugin: AmplitudeSwiftSessionReplayPlugin())
```

[Developer docs](https://amplitude.com/docs/session-replay/session-replay-ios-plugin)

### Amplitude-iOS

1. Make sure the Analytics SDK is on version 8.22.0 or higher
  
2. Use target/subspec: `AmplitudeiOSSessionReplayMiddleware`

3. Import the framework:
```
import AmplitudeiOSSessionReplayMiddleware
```

4. Add the plugin to your Amplitude instance:
```
amplitude.addEventMiddleware(AmplitudeiOSSessionReplayMiddleware())
```

[Developer docs](https://amplitude.com/docs/session-replay/session-replay-ios-middleware)

### Segment (Analytics-Swift, Amplitude (Actions) Destination, SegmentAmplitude Plugin)

1. Use target/subspec: `AmplitudeSegmentSessionReplayPlugin`

2. Import the framework:
```
import AmplitudeSegmentSessionReplayPlugin
```

3. Add the plugin to your Amplitude instance, after adding the AmplitudeSession plugin:
```
let analytics = Analytics(configuration: config)
// AmplitudeSession MUST be first so AmplitudeSegmentSessionReplayPlugin can pick up the sessionId
analytics.add(plugin: AmplitudeSession())
analytics.add(plugin: AmplitudeSegmentSessionReplayPlugin(amplitudeApiKey: "AMPLITUDE_API_KEY"))
```

[Developer docs](https://amplitude.com/docs/session-replay/session-replay-ios-segment-integration)

### Standalone / Third Party

1. Use target/subspec: `AmplitudeSessionReplay`

2. Import the framework:
```
import AmplitudeSessionReplay
```

3. Initialize `AmplitudeSessionReplay`, and make sure to retain a copy of the instance:
```
let sessionReplay = SessionReplay(apiKey: "API_KEY")
```

4. Set `deviceId` and `sessionId` on the `SessionReplay` instance, equivalent to that set on your analytics client.
```
sessionReplay.deviceId = deviceId
sessionReplay.sessionId = sessionId
``` 

5. Add `additionalEventProperties` as event properties to the events you pass to Amplitude.
```
var eventProperties = event.eventProperties ?? [:]
eventProperties.merge(sessionReplay.additionalEventProperties) { (current, _) in current }
event.eventProperties = eventProperties
```

6. Call start:
```
sessionReplay.start()
```

[Developer docs](https://amplitude.com/docs/session-replay/session-replay-ios-standalone-sdk)

## Need Help?
If you have any issues using our SDK, feel free to [create a GitHub issue](https://github.com/amplitude/AmplitudeSessionReplay-iOS/issues/new/choose) or submit a request on [Amplitude Help](https://help.amplitude.com/hc/en-us/requests/new).
