// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PrivacyBoost",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PrivacyBoost",
            targets: ["PrivacyBoost", "PrivacyBoostFFI"]
        ),
        .library(
            name: "PrivacyBoostDefaults",
            targets: ["PrivacyBoostDefaults"]
        ),
    ],
    targets: [
        .target(
            name: "PrivacyBoost",
            dependencies: ["PrivacyBoostFFI"],
            path: "Sources/PrivacyBoost"
        ),
        .target(
            name: "PrivacyBoostDefaults",
            dependencies: ["PrivacyBoost"],
            path: "Sources/PrivacyBoostDefaults"
        ),
        .binaryTarget(
            name: "PrivacyBoostFFI",
            url: "https://github.com/sunnyside-io/privacy-boost-sdk/releases/download/v1.3.1/PrivacyBoostFFI.xcframework.zip",
            checksum: "dda5175337335faee1c02a5da4856a03cf9d5e6d1ce9b549583127727c77cf16"
        ),
    ]
)
