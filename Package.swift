// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StarPRNT",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "StarIO", targets: ["StarIO"]),
        .library(name: "StarIO_Extension", targets: ["StarIO_Extension"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "StarIO", path: "./SDK/Pods/StarIO/StarIO.xcframework"),
        .binaryTarget(name: "StarIO_Extension", path: "./SDK/Pods/StarIO_Extension/StarIO_Extension.xcframework"),
    ]
)


