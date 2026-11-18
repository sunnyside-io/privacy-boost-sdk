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
            url: "https://github.com/sunnyside-io/privacy-boost-sdk/releases/download/v1.3.3/PrivacyBoostFFI.xcframework.zip",
            checksum: "f150e62082d28126e2a36b2d594873ddc204e4b004bbf5f8b38ca21584ba9f2b"
        ),
    ]
)
