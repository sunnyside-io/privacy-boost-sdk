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
              url: "https://github.com/testinprod-io/privacy-boost-sdk/releases/download/v0.2.0/PrivacyBoostFFI.xcframework.zip",
              checksum: "43c0a21260dd0f3c295834dfd8ba646596205dd96713319ff57c404ffff4e2a3"
          ),
    ]
)
