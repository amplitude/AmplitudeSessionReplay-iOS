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
    private let quality: QualityProfile
    private let enableRemoteConfig: Bool
    private let uploadConfig: UploadConfig
    private let webviewMappings: [String: String]
    private let autoStart: Bool
    private let captureWebViews: Bool
    private let recordLogOptions: RecordLogOptions

    /// Shares the plugin configuration type so capture options stay aligned.
    public typealias Config = SessionReplayPlugin.Config

    private let lock = NSRecursiveLock()
    private var amplitudeSessionId: Int64 = -1
    private var replay: SessionReplay?
    private var customId: String?
    private var localPrivacyConfig: PrivacyConfig

    /// Overrides the Analytics session ID. Set nil to restore its latest session ID.
    @objc public var customSessionId: String? {
        get { lock.withLock { customId } }
        set {
            lock.withLock {
                customId = newValue
                if let newValue {
                    replay?.customSessionId = newValue
                } else {
                    replay?.sessionId = amplitudeSessionId
                }
            }
        }
    }

    /// The attached core client. Prefer middleware setters for synchronized identity updates.
    @objc public var sessionReplay: SessionReplay? {
        get { lock.withLock { replay } }
        set {
            lock.withLock {
                replay = newValue
                if let customId {
                    replay?.customSessionId = customId
                }
            }
        }
    }

    /// Local privacy settings. Remote configuration retains precedence, as in the plugin.
    @objc public var privacyConfig: PrivacyConfig {
        get { lock.withLock { localPrivacyConfig } }
        set {
            lock.withLock {
                localPrivacyConfig = newValue
                replay?.privacyConfig = newValue
            }
        }
    }

    /// Creates middleware using the same capture configuration as the plugin.
    @objc public convenience init(config: Config) {
        self.init(sampleRate: config.sampleRate,
                  maskLevel: config.maskLevel,
                  quality: config.quality,
                  enableRemoteConfig: config.enableRemoteConfig,
                  uploadConfig: config.uploadConfig,
                  webviewMappings: config.webviewMappings,
                  autoStart: config.autoStart,
                  captureWebViews: config.captureWebViews,
                  recordLogOptions: config.recordLogOptions)
    }

    @objc public init(sampleRate: Float = 0.0,
                      maskLevel: MaskLevel = .medium,
                      quality: QualityProfile = .high,
                      enableRemoteConfig: Bool = true,
                      uploadConfig: UploadConfig = UploadConfig(),
                      webviewMappings: [String: String] = [:],
                      autoStart: Bool = true,
                      captureWebViews: Bool = false,
                      recordLogOptions: RecordLogOptions = .init()) {
        self.sampleRate = sampleRate
        self.localPrivacyConfig = PrivacyConfig(maskLevel: maskLevel)
        self.quality = quality
        self.enableRemoteConfig = enableRemoteConfig
        self.uploadConfig = uploadConfig
        self.webviewMappings = webviewMappings
        self.autoStart = autoStart
        self.captureWebViews = captureWebViews
        self.recordLogOptions = recordLogOptions
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

        lock.withLock {
            replay?.stop()
            amplitudeSessionId = amplitude.getSessionId()
            sessionReplay = SessionReplay(apiKey: amplitude.apiKey,
                                          deviceId: amplitude.getDeviceId(),
                                          sessionId: amplitude.getSessionId(),
                                          optOut: amplitude.optOut,
                                          sampleRate: sampleRate,
                                          quality: quality,
                                          webviewMappings: webviewMappings,
                                          serverZone: serverZone,
                                          maskLevel: localPrivacyConfig.maskLevel,
                                          enableRemoteConfig: enableRemoteConfig,
                                          uploadConfig: uploadConfig,
                                          captureWebViews: captureWebViews,
                                          recordLogOptions: recordLogOptions)
            if autoStart {
                sessionReplay?.start()
            }
        }
    }

    public func amplitude(_ amplitude: Amplitude, didChangeDeviceId deviceId: String) {
        lock.withLock { replay?.deviceId = deviceId }
    }

    public func amplitude(_ amplitude: Amplitude, didChangeSessionId sessionId: Int64) {
        lock.withLock {
            amplitudeSessionId = sessionId
            if customId == nil {
                replay?.sessionId = sessionId
            }
        }
    }

    public func amplitude(_ amplitude: Amplitude, didOptOut optOut: Bool) {
        lock.withLock { replay?.optOut = optOut }
    }

    public func run(_ payload: AMPMiddlewarePayload, next: @escaping AMPMiddlewareNext) {
        lock.withLock {
            guard let sessionReplay = replay,
                  customId != nil || sessionReplay.sessionId == payload.event["session_id"] as? CLongLong,
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
        }
        // Continue outside the lock, including events that cannot be enriched.
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

    @objc public func start() {
        sessionReplay?.start()
    }

    @objc public func stop() {
        sessionReplay?.stop()
    }

    @objc public func recordLog(level: RecordLogLevel, message: String?, date: Date = Date()) {
        sessionReplay?.recordLog(level: level, message: message, date: date)
    }
}
