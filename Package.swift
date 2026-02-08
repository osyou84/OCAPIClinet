// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OCAPIClient",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "OCAPIClient",
            targets: ["OCAPIClient"]),
    ],
    targets: [
        .target(
            name: "OCAPIClient",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]),
        .testTarget(
            name: "OCAPIClientTests",
            dependencies: ["OCAPIClient"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]),
    ]
)
