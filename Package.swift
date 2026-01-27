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
            url: "https://github.com/testinprod-io/privacy-boost/releases/download/v0.1.2/PrivacyBoostFFI.xcframework.zip",
            checksum: "dbfaa667e5ff7bd98fba6b74c68cc096ec2ff0105f87aef26a679ba993bd80b9"
        ),
    ]
)
