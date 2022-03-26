// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OCAPIClient",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)
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
    ]
)
