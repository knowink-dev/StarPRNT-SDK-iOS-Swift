// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StarIO",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "StarIO", targets: ["StarIO"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "StarIO", path: "./SDK/Pods/StarIO/StarIO.xcframework"),
    ]
)


