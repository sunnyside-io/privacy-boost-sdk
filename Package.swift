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
        .binaryTarget(
            name: "PrivacyBoostFFI",
        url: "https://github.com/testinprod-io/privacy-boost-sdk/releases/download/v0.1.4/PrivacyBoostFFI.xcframework.zip",
            checksum: "ca9b700f6cfd768280e567dd952dbd4bae17ab69a2f98ee038a7e9565b3b3ba5"
        ),
    ]
)
