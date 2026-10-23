// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AlqamiNative",
    defaultLocalization: "ar",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AlqamiNative",
            targets: ["AlqamiNative"]
        )
    ],
    targets: [
        .target(
            name: "AlqamiNative",
            path: "AlqamiNative",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
