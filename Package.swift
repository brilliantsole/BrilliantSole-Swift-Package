// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BrilliantSole",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10), .tvOS(.v17), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BrilliantSole",
            targets: ["BrilliantSole"]
        ),
    ],
    dependencies: [
        // ignore warning - removing (name: "UkatonMacros") prevents compilation
        .package(name: "UkatonMacros", url: "https://github.com/zakaton/UkatonSwiftMacros.git", branch: "main"),
        .package(name: "iOSMcuManagerLibrary", url: "https://github.com/brilliantsole/IOS-nRF-Connect-Device-Manager.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BrilliantSole",
            dependencies: ["UkatonMacros", "iOSMcuManagerLibrary"]
        ),
        .testTarget(
            name: "BrilliantSoleTests",
            dependencies: ["BrilliantSole"],
            resources: [
                .copy("Resources/model.tflite"),
                .copy("Resources/firmware.bin"),
                .copy("Resources/firmware2.bin"),
                .copy("Resources/firmware3.bin"),
            ]
        ),
    ]
)
