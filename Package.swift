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
            url: "https://github.com/sunnyside-io/privacy-boost-sdk/releases/download/v1.0.5/PrivacyBoostFFI.xcframework.zip",
            checksum: "be16219a17e9b9e543af0aecb130b3f951b93441c64a9bfea23e539720b6f16a"
        ),
    ]
)
