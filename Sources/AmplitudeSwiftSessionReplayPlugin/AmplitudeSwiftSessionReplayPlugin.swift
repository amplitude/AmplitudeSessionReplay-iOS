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

    private var sessionReplay: SessionReplay?

    @objc public init(sampleRate: Float = 1.0) {
        self.sampleRate = sampleRate
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
                                      serverZone: serverZone)
        sessionReplay?.start()
    }

    public func onUserIdChanged(_ userId: String?) {
        // no-op
    }

    public func onDeviceIdChanged(_ deviceId: String?) {
        sessionReplay?.deviceId = deviceId
    }

    public func onSessionIdChanged(_ sessionId: Int64) {
        sessionReplay?.sessionId = sessionId
    }

    public func onOptOutChanged(_ optOut: Bool) {
        sessionReplay?.optOut = optOut
    }

    public func execute(event: BaseEvent) -> BaseEvent? {
        guard let sessionReplay = sessionReplay else {
            return event
        }

        var eventProperties = event.eventProperties ?? [:]
        eventProperties.merge(sessionReplay.additionalEventProperties) { (current, _) in current }
        event.eventProperties = eventProperties

        return event
    }

    public func teardown() {
        sessionReplay?.stop()
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
