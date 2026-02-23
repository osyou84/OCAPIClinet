// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OCAPIClient",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "OCAPIClient",
            targets: ["OCAPIClient"]),
    ],
    targets: [
        .target(
            name: "OCAPIClient",
            dependencies: []),
        .testTarget(
            name: "OCAPIClientTests",
            dependencies: ["OCAPIClient"]),
    ],
    swiftLanguageModes: [.v6]
)
