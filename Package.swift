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
            url: "https://github.com/testinprod-io/privacy-boost/releases/download/v0.1.0/PrivacyBoostFFI.xcframework.zip",
            checksum: "b912eb6c0aeda78d990bebb85d6bb0c73245077383fd8be239aec4686c71f2e5"
        ),
    ]
)
