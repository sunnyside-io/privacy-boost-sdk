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
              url: "https://github.com/testinprod-io/privacy-boost-sdk/releases/download/v0.2.2/PrivacyBoostFFI.xcframework.zip",
              checksum: "bac289beb77c4cc9e9fef30f1ff1362f469cd86bc60d572f748b8147983aaed9"
          ),
    ]
)
