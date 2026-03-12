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
              url: "https://github.com/testinprod-io/privacy-boost-sdk/releases/download/v0.2.3/PrivacyBoostFFI.xcframework.zip",
              checksum: "d10f5913d0c7b708e2941215b4a77a12f82575662808f61d234974893065f5ef"
          ),
    ]
)
