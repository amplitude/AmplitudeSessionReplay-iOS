// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmplitudeSessionReplay",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15), // We don’t actually support macOS; this is just to allow running the Swift command line tool.
    ],
    products: [
        .library(
            name: "AmplitudeSessionReplay",
            targets: ["AmplitudeSessionReplayWrapper"]),
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
        .package(url: "https://github.com/amplitude/AmplitudeCore-Swift.git", from: "1.0.13"),
        .package(url: "https://github.com/amplitude/Amplitude-iOS.git", from: "8.22.0"),
        .package(url: "https://github.com/segmentio/analytics-swift", "1.5.0"..<"2.0.0"),
    ],
    targets: [
        .binaryTarget(name: "AmplitudeSessionReplay",
                      path: "Frameworks/AmplitudeSessionReplay.xcframework"),
        .target(name: "AmplitudeSessionReplayWrapper",
                dependencies: [
                    .target(name: "AmplitudeSessionReplay"),
                    .product(name: "AmplitudeCoreFramework", package: "AmplitudeCore-Swift")
                ]),
        .target(name: "AmplitudeSwiftSessionReplayPlugin",
                dependencies: [
                    .target(name: "AmplitudeSessionReplayWrapper"),
                ]),
        .target(name: "AmplitudeiOSSessionReplayMiddleware",
                dependencies: [
                    .target(name: "AmplitudeSessionReplayWrapper"),
                    .product(name: "Amplitude", package: "Amplitude-iOS"),
                ]),
        .target(name: "AmplitudeSegmentSessionReplayPlugin",
                dependencies: [
                    .target(name: "AmplitudeSessionReplayWrapper"),
                    .product(name: "Segment", package: "analytics-swift"),
                ]),
    ]
)
