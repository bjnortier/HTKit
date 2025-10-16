// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HTKit",
            targets: ["HTKit"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HTKit", dependencies: ["whisper.xcframework"]
        ),
        .binaryTarget(
            name: "whisper.xcframework",
            url: "https://github.com/ggml-org/whisper.cpp/releases/download/v1.8.2/whisper-v1.8.2-xcframework.zip",
            checksum: "3ffeec1df254d908f01ee3d87bf0aedb8fbc8f29cbf50dc8702741bb85381385"),
        .testTarget(
            name: "HTKitTests",
            dependencies: ["HTKit"],
            resources: [
                .copy("Resources/jfk.wav"),
                .copy("Resources/aragorn.wav"),
                .copy("Resources/ggml-tiny.bin"),
            ]
        ),
    ]
)
