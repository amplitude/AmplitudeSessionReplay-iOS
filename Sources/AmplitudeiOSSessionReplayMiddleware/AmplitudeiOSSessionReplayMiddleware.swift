//
//  AmplitudeiOSSessionReplayMiddleware.swift
//  AmplitudeSessionReplayIos
//
//  Created by Chris Leonavicius on 8/7/24.
//

import Amplitude
import AmplitudeSessionReplay

@objc public class AmplitudeiOSSessionReplayMiddleware: NSObject, AMPMiddleware {

    private let sampleRate: Float
    private let serverUrl: String?

    private var sessionReplay: SessionReplay?

    @objc public init(sampleRate: Float = 1.0, serverUrl: String? = nil) {
        self.sampleRate = sampleRate
        self.serverUrl = serverUrl
    }

    public func amplitudeDidFinishInitializing(_ amplitude: Amplitude) {
        let serverZone: AmplitudeSessionReplay.ServerZone
        switch amplitude.serverZone() {
        case .US:
            serverZone = .US
        case .EU:
            serverZone = .EU
        @unknown default:
            serverZone = .US
        }

        sessionReplay = SessionReplay(apiKey: amplitude.apiKey,
                                      deviceId: amplitude.getDeviceId(),
                                      sessionId: amplitude.getSessionId(),
                                      optOut: amplitude.optOut,
                                      sampleRate: sampleRate,
                                      serverZone: serverZone,
                                      serverUrl: serverUrl)
        sessionReplay?.start()
    }

    public func run(_ payload: AMPMiddlewarePayload, next: @escaping AMPMiddlewareNext) {
        guard let sessionReplay = sessionReplay else {
            return
        }

        let sessionId = payload.event["session_id"] as? Int64
        let deviceId = payload.event["device_id"] as? String

        sessionReplay.deviceId = deviceId
        sessionReplay.sessionId = sessionId ?? -1

        let eventProperties: NSMutableDictionary
        switch payload.event["event_properties"] {
        case let existingEventProperties as NSMutableDictionary:
            eventProperties = existingEventProperties
        case let existingEventProperties as NSDictionary:
            eventProperties = NSMutableDictionary(dictionary: existingEventProperties)
        default:
            eventProperties = NSMutableDictionary()
        }
        eventProperties.addEntries(from: sessionReplay.additionalEventProperties)
        payload.event["event_properties"] = eventProperties

        next(payload);
    }

    public func amplitude(_ amplitude: Amplitude, didUploadEventsManually manually: Bool) {
        if manually {
            sessionReplay?.flush()
        }
    }
}
