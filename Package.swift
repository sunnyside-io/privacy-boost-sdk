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
            url: "https://github.com/testinprod-io/privacy-boost/releases/download/v0.1.1/PrivacyBoostFFI.xcframework.zip",
            checksum: "3f919c15717938553378dd27ff209008899c3c6944f95c338bb281629a15ff45"
        ),
    ]
)
