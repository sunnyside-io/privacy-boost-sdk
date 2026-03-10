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
              url: "https://github.com/testinprod-io/privacy-boost-sdk/releases/download/v0.2.1/PrivacyBoostFFI.xcframework.zip",
              checksum: "5582d70a16ebdbea33b6c9234e4ca3a43ed4d976ed132c9ea4012b126f82bb92"
          ),
    ]
)
