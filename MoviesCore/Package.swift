// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MoviesCore",
    platforms: [.macOS(.v12), .iOS(.v13)],
    products: [
        .library(
            name: "MoviesCore",
            type: .static,
            targets: ["MoviesCore"]),
    ],
    targets: [
        .target(
            name: "MoviesCore",
            dependencies: []),
        .testTarget(
            name: "MoviesCoreTests",
            dependencies: ["MoviesCore"]
        )
    ]
)
