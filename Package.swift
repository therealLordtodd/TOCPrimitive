// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TOCPrimitive",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "TOCPrimitive",
            targets: ["TOCPrimitive"]
        ),
    ],
    dependencies: [
        .package(path: "../ContentModelPrimitive"),
        .package(path: "../ReaderChromeThemePrimitive"),
    ],
    targets: [
        .target(
            name: "TOCPrimitive",
            dependencies: [
                .product(name: "ContentModelPrimitive", package: "ContentModelPrimitive"),
                .product(name: "ReaderChromeThemePrimitive", package: "ReaderChromeThemePrimitive"),
            ]
        ),
        .testTarget(
            name: "TOCPrimitiveTests",
            dependencies: ["TOCPrimitive"]
        ),
    ]
)
