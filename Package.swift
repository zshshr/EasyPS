// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickStampSign",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "QuickStampSign",
            targets: ["QuickStampSign"]),
    ],
    dependencies: [
        // No external dependencies - using Apple frameworks only
    ],
    targets: [
        .target(
            name: "QuickStampSign",
            dependencies: [],
            path: "QuickStampSign"),
        .testTarget(
            name: "QuickStampSignTests",
            dependencies: ["QuickStampSign"],
            path: "QuickStampSignTests"),
    ]
)
