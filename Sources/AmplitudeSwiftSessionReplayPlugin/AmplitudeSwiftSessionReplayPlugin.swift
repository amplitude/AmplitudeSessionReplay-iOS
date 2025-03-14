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
                                      webviewMappings: webviewMappings,
                                      logger: LoggerWrapper(amplitude.configuration.loggerProvider),
                                      serverZone: serverZone,
                                      maskLevel: maskLevel,
                                      enableRemoteConfig: enableRemoteConfig)
        if autoStart {
            sessionReplay?.start()
        }
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
        guard let sessionReplay = sessionReplay,
              sessionReplay.sessionId == event.sessionId,
              sessionReplay.deviceId == event.deviceId else {
            return event
        }

        var eventProperties = event.eventProperties ?? [:]
        eventProperties.merge(sessionReplay.additionalEventProperties) { (current, _) in current }
        event.eventProperties = eventProperties

        return event
    }

    public func start() {
        sessionReplay?.start()
    }

    public func stop() {
        sessionReplay?.stop()
    }

    public func teardown() {
        sessionReplay?.stop()
    }
}

private final class LoggerWrapper: AmplitudeSessionReplay.Logger {

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
