// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmplitudeSessionReplay",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AmplitudeSessionReplay",
            targets: ["AmplitudeSessionReplay"]),
        .library(
            name: "AmplitudeSwiftSessionReplayPlugin",
            targets: ["AmplitudeSwiftSessionReplayPlugin"]),
        .library(
            name: "AmplitudeiOSSessionReplayMiddleware",
            targets: ["AmplitudeiOSSessionReplayMiddleware"]),
        .library(
            name: "AmplitudeSegmentSessionReplayPlugin",
            targets: ["AmplitudeSegmentSessionReplayPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/amplitude/Amplitude-Swift.git", from: "1.9.2"),
        .package(url: "https://github.com/amplitude/Amplitude-iOS.git", from: "8.22.0"),
        .package(url: "https://github.com/segmentio/analytics-swift", "1.5.0"..<"2.0.0"),
    ],
    targets: [
        .binaryTarget(name: "AmplitudeSessionReplay",
                      path: "Frameworks/AmplitudeSessionReplay.xcframework"),
        .target(name: "AmplitudeSwiftSessionReplayPlugin",
                dependencies: [
                    .target(name: "AmplitudeSessionReplay"),
                    .product(name: "AmplitudeSwift", package: "Amplitude-Swift"),
                ]),
        .target(name: "AmplitudeiOSSessionReplayMiddleware",
                dependencies: [
                    .target(name: "AmplitudeSessionReplay"),
                    .product(name: "Amplitude", package: "Amplitude-iOS"),
                ]),
        .target(name: "AmplitudeSegmentSessionReplayPlugin",
                dependencies: [
                    .target(name: "AmplitudeSessionReplay"),
                    .product(name: "Segment", package: "analytics-swift"),
                ]),
    ]
)