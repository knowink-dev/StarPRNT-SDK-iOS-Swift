// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StarIO_Extension",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "StarIO_Extension", targets: ["StarIO_Extension"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "StarIO_Extension", path: "./SDK/Pods/StarIO_Extension/StarIO_Extension.xcframework"),
    ]
)


