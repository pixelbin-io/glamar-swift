// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GlamAR",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GlamAR",
            targets: ["GlamAR"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")), // Alamofire dependency
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GlamAR",
            dependencies: ["Alamofire"]),
        // 👇 Add this target for your example app
                .target(
                    name: "ExampleApp",
                    dependencies: ["GlamAR"],
                    path: "example"
                )
    ]
)
