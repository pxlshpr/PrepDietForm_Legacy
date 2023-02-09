// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrepDietForm",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PrepDietForm",
            targets: ["PrepDietForm"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/EmojiPicker", from: "0.0.22"),
        .package(url: "https://github.com/pxlshpr/PrepDataTypes", from: "0.0.255"),
        .package(url: "https://github.com/pxlshpr/PrepCoreDataStack", from: "0.0.29"),
        .package(url: "https://github.com/pxlshpr/PrepViews", from: "0.0.147"),
        .package(url: "https://github.com/pxlshpr/SwiftHaptics", from: "0.1.3"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.366"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrepDietForm",
            dependencies: [
                .product(name: "EmojiPicker", package: "emojipicker"),
                .product(name: "PrepDataTypes", package: "prepdatatypes"),
                .product(name: "PrepCoreDataStack", package: "prepcoredatastack"),
                .product(name: "PrepViews", package: "prepviews"),
                .product(name: "SwiftHaptics", package: "swifthaptics"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
            ]),
        .testTarget(
            name: "PrepDietFormTests",
            dependencies: ["PrepDietForm"]),
    ]
)
