import Amplitude
import AmplitudeSessionReplay
@testable import AmplitudeiOSSessionReplayMiddleware
import XCTest

final class MiddlewareTests: XCTestCase {
    func testCustomSessionSurvivesHostChangesAndClearingRestoresLatestSession() {
        let middleware = AmplitudeiOSSessionReplayMiddleware(autoStart: false)
        let replay = SessionReplay(apiKey: "test-api-key", deviceId: "device", sessionId: 10,
                                   sampleRate: 1, enableRemoteConfig: false)
        middleware.customSessionId = "snowplow-session"
        middleware.sessionReplay = replay
        XCTAssertEqual(replay.customSessionId, "snowplow-session")
        let amplitude = Amplitude.instance(withName: "middleware-parity")
        middleware.amplitude(amplitude, didChangeSessionId: 20)
        middleware.amplitude(amplitude, didChangeDeviceId: "next-device")
        XCTAssertEqual(replay.customSessionId, "snowplow-session")
        XCTAssertEqual(replay.deviceId, "next-device")
        middleware.customSessionId = nil
        XCTAssertEqual(replay.sessionId, 20)
    }

    func testCustomSessionEnrichmentAndMismatchedEventsContinue() {
        let middleware = AmplitudeiOSSessionReplayMiddleware(autoStart: false)
        middleware.sessionReplay = SessionReplay(apiKey: "test-api-key", deviceId: "device", sessionId: 10,
                                                 sampleRate: 1, enableRemoteConfig: false)
        middleware.start()
        defer { middleware.stop() }
        for customId in ["snowplow-session", "12345"] {
            middleware.customSessionId = customId
            let payload = AMPMiddlewarePayload(event: ["device_id": "device", "session_id": 20], withExtra: nil)
            var calls = 0
            middleware.run(payload) { _ in calls += 1 }
            XCTAssertEqual(calls, 1)
            let properties = payload.event["event_properties"] as? NSDictionary
            XCTAssertEqual(properties?["[Amplitude] Session Replay ID"] as? String, "device/\(customId)")
        }
        let mismatch = AMPMiddlewarePayload(event: ["device_id": "other", "session_id": 20], withExtra: nil)
        var calls = 0
        middleware.run(mismatch) { _ in calls += 1 }
        XCTAssertEqual(calls, 1)
        XCTAssertNil(mismatch.event["event_properties"])
    }

    func testOptionsSetBeforeInitializationReachCore() {
        let initialized = expectation(description: "middleware initialized")
        let uploadConfig = UploadConfig(serverUrl: "https://example.invalid/replay")
        let middleware = ObservingMiddleware(config: .init(sampleRate: 0.5,
                                                           quality: .low,
                                                           enableRemoteConfig: false,
                                                           autoStart: false,
                                                           uploadConfig: uploadConfig))
        middleware.customSessionId = "before-initialize"
        middleware.privacyConfig = PrivacyConfig(maskLevel: .conservative)
        middleware.onInitialized = { initialized.fulfill() }
        let amplitude = Amplitude.instance(withName: UUID().uuidString)
        amplitude.addEventMiddleware(middleware)
        amplitude.initializeApiKey("test-api-key")
        wait(for: [initialized], timeout: 10)
        XCTAssertEqual(middleware.sessionReplay?.customSessionId, "before-initialize")
        XCTAssertEqual(middleware.sessionReplay?.privacyConfig.maskLevel, .conservative)
        XCTAssertEqual(middleware.sessionReplay?.sampleRate, 0.5)
        XCTAssertEqual(middleware.sessionReplay?.quality, .low)
        XCTAssertEqual(middleware.sessionReplay?.enableRemoteConfig, false)
        XCTAssertTrue(middleware.sessionReplay?.uploadConfig === uploadConfig)
        middleware.stop()
    }

    func testConfigAndRuntimePrivacy() {
        let middleware = AmplitudeiOSSessionReplayMiddleware(config: .init(maskLevel: .light, autoStart: false))
        XCTAssertEqual(middleware.privacyConfig.maskLevel, .light)
        let replay = SessionReplay(apiKey: "test-api-key", enableRemoteConfig: false)
        middleware.sessionReplay = replay
        middleware.privacyConfig = PrivacyConfig(maskLevel: .conservative)
        XCTAssertEqual(replay.privacyConfig.maskLevel, .conservative)
    }
}

private final class ObservingMiddleware: AmplitudeiOSSessionReplayMiddleware {
    var onInitialized: (() -> Void)?

    override func amplitudeDidFinishInitializing(_ amplitude: Amplitude) {
        super.amplitudeDidFinishInitializing(amplitude)
        onInitialized?()
    }
}
