// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BrilliantKit",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10), .tvOS(.v17), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BrilliantKit",
            targets: ["BrilliantKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/zakaton/UkatonSwiftMacros.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BrilliantKit"),
        .testTarget(
            name: "BrilliantKitTests",
            dependencies: ["BrilliantKit"]
        ),
    ]
)
