// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StarPRNT",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "StarPRNT", targets: ["StarIO"]),
    ],
    dependencies: [.package(url: "git@github.com:knowink-dev/StarPRNT-SDK-iOS-Swift.git", exact: "1.0.0-starIO-extension")],
    targets: [
        .binaryTarget(name: "StarIO", path: "./SDK/Pods/StarIO/StarIO.xcframework"),
    ]
)


