//
//  AmplitudeSwiftSessionReplayPlugin.swift
//  AmplitudeSessionReplayIos
//
//  Created by Chris Leonavicius on 8/7/24.
//

import AmplitudeSwift
import AmplitudeSessionReplay

@objc public class AmplitudeSwiftSessionReplayPlugin: NSObject, Plugin {

    public let type = PluginType.enrichment

    private static let sessionReplayProperty = "[Amplitude] Session Replay ID"

    private let sampleRate: Float
    private let serverUrl: String?

    private var sessionReplay: SessionReplay?

    @objc public init(sampleRate: Float = 1.0, serverUrl: String? = nil) {
        self.sampleRate = sampleRate
        self.serverUrl = serverUrl
    }

    public func setup(amplitude: Amplitude) {
        let serverZone: AmplitudeSessionReplay.ServerZone
        switch amplitude.configuration.serverZone {
        case .US:
            serverZone = .US
        case .EU:
            serverZone = .EU
        }

        sessionReplay = SessionReplay(apiKey: amplitude.configuration.apiKey,
                                      deviceId: amplitude.getDeviceId(),
                                      sessionId: amplitude.getSessionId(),
                                      optOut: amplitude.configuration.optOut,
                                      sampleRate: sampleRate,
                                      logger: LoggerWrapper(amplitude.configuration.loggerProvider),
                                      serverZone: serverZone,
                                      serverUrl: serverUrl)
        sessionReplay?.start()
    }

    public func execute(event: BaseEvent) -> BaseEvent? {
        guard let sessionReplay = sessionReplay else {
            return event
        }
        sessionReplay.deviceId = event.deviceId
        sessionReplay.sessionId = event.sessionId ?? -1

        var eventProperties = event.eventProperties ?? [:]
        eventProperties.merge(sessionReplay.additionalEventProperties) { (current, _) in current }
        event.eventProperties = eventProperties

        return event
    }
}

fileprivate final class LoggerWrapper: AmplitudeSessionReplay.Logger {

    private let logger: any AmplitudeSwift.Logger

    init(_ logger: any AmplitudeSwift.Logger) {
        self.logger = logger
    }

    func error(message: String) {
        logger.error(message: message)
    }

    func warn(message: String) {
        logger.warn(message: message)
    }

    func log(message: String) {
        logger.log(message: message)
    }

    func debug(message: String) {
        logger.debug(message: message)
    }
}
