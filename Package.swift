// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JPImageresizerView",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "JPImageresizerView",
            targets: ["JPImageresizerView"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "JPImageresizerView",
            dependencies: [],
            path: "JPImageresizerView",
            sources: ["Classes"],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ],
            publicHeadersPath: "include"
        ),
    ]
)
