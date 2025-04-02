//
//  AmplitudeiOSSessionReplayMiddleware.swift
//  AmplitudeSessionReplayIos
//
//  Created by Chris Leonavicius on 8/7/24.
//

import Amplitude
import AmplitudeCore
import AmplitudeSessionReplay

@objc public class AmplitudeiOSSessionReplayMiddleware: NSObject, AMPMiddleware {

    private let sampleRate: Float
    private let maskLevel: MaskLevel
    private let enableRemoteConfig: Bool
    private let webviewMappings: [String: String]
    private let autoStart: Bool

    private var sessionReplay: SessionReplay?

    @objc public init(sampleRate: Float = 0.0,
                      maskLevel: MaskLevel = .medium,
                      enableRemoteConfig: Bool = true,
                      webviewMappings: [String: String] = [:],
                      autoStart: Bool = true) {
        self.sampleRate = sampleRate
        self.maskLevel = maskLevel
        self.enableRemoteConfig = enableRemoteConfig
        self.webviewMappings = webviewMappings
        self.autoStart = autoStart
    }

    public func amplitudeDidFinishInitializing(_ amplitude: Amplitude) {
        let serverZone: AmplitudeCore.ServerZone
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
                                      webviewMappings: webviewMappings,
                                      serverZone: serverZone,
                                      maskLevel: maskLevel,
                                      enableRemoteConfig: enableRemoteConfig)
        if autoStart {
            sessionReplay?.start()
        }
    }

    public func amplitude(_ amplitude: Amplitude, didChangeDeviceId deviceId: String) {
        sessionReplay?.deviceId = deviceId
    }

    public func amplitude(_ amplitude: Amplitude, didChangeSessionId sessionId: Int64) {
        sessionReplay?.sessionId = sessionId
    }

    public func amplitude(_ amplitude: Amplitude, didOptOut optOut: Bool) {
        sessionReplay?.optOut = optOut
    }

    public func run(_ payload: AMPMiddlewarePayload, next: @escaping AMPMiddlewareNext) {
        guard let sessionReplay = sessionReplay,
              sessionReplay.sessionId == payload.event["session_id"] as? CLongLong,
              sessionReplay.deviceId == payload.event["device_id"] as? String else {
            return
        }

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

        next(payload)
    }

    public func amplitude(_ amplitude: Amplitude, didUploadEventsManually manually: Bool) {
        if manually {
            sessionReplay?.flush()
        }
    }

    public func amplitudeDidRemove(_ amplitude: Amplitude) {
        sessionReplay?.stop()
    }

    public func start() {
        sessionReplay?.start()
    }

    public func stop() {
        sessionReplay?.stop()
    }
}
