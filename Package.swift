// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PrivacyBoost",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "PrivacyBoost",
            targets: ["PrivacyBoost", "PrivacyBoostFFI"]
        ),
    ],
    targets: [
        .target(
            name: "PrivacyBoost",
            dependencies: ["PrivacyBoostFFI"],
            path: "Sources/PrivacyBoost"
        ),
        // Binary target is updated automatically by CI on each release.
        // See: https://github.com/testinprod-io/privacy-boost/releases
        .binaryTarget(
            name: "PrivacyBoostFFI",
            url: "https://github.com/testinprod-io/privacy-boost/releases/download/v0.0.15/PrivacyBoostFFI.xcframework.zip",
            checksum: "PLACEHOLDER"
        ),
    ]
)
