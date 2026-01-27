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
            url: "https://github.com/testinprod-io/privacy-boost/releases/download/v0.1.3/PrivacyBoostFFI.xcframework.zip",
            checksum: "42fcc048eda1a6d646947a2aa29652428067c1c686eb7c29c4f9542583969fa2"
        ),
    ]
)
