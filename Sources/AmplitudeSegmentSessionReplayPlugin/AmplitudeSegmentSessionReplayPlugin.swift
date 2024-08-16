//
//  SegmentSessionReplayPlugin.swift
//  AmplitudeSessionReplayIos
//
//  Created by Chris Leonavicius on 8/16/24.
//

import AmplitudeSessionReplay
import Segment

public class AmplitudeSegmentSessionReplayPlugin: Plugin {

    private let sessionReplay: SessionReplay

    public let type: PluginType = .enrichment

    public var analytics: Analytics?

    public init(amplitudeApiKey apiKey: String,
                sampleRate: Float = 1.0,
                serverZone: ServerZone = .US,
                serverUrl: String? = nil) {
        sessionReplay = SessionReplay(apiKey: apiKey,
                                      sampleRate: sampleRate,
                                      serverZone: serverZone,
                                      serverUrl: serverUrl)
    }

    public func configure(analytics: Analytics) {
        sessionReplay.start()
    }

    public func execute<T: RawEvent>(event: T?) -> T? {
        guard let event = event else {
            return event
        }

        let amplitudeProperties = event.integrations?["Actions Amplitude"]

        let eventProperties: JSON?
        switch event {
        case let trackEvent as TrackEvent:
            eventProperties = trackEvent.properties
        case let screenEvent as ScreenEvent:
            eventProperties = screenEvent.properties
        default:
            eventProperties = nil
        }

        sessionReplay.deviceId = event.context?["device"]?["id"]?.stringValue ?? event.anonymousId
        sessionReplay.sessionId = Int64((amplitudeProperties?["session_id"] ?? eventProperties?["session_id"])?.intValue ?? -1)

        let additionalEventProperties = sessionReplay.additionalEventProperties

        if !additionalEventProperties.isEmpty {
            var properties = eventProperties?.dictionaryValue ?? [:]
            properties.merge(additionalEventProperties) { (current, _) in current }

            switch event {
            case var trackEvent as TrackEvent:
                trackEvent.properties = (try? JSON(properties)) ?? trackEvent.properties
                return trackEvent as? T
            case var screenEvent as ScreenEvent:
                screenEvent.properties = (try? JSON(properties)) ?? screenEvent.properties
                return screenEvent as? T
            default:
                break
            }
        }

        return event
    }
}
