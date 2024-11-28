// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "doc_scan_kit",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "doc-scan-kit", targets: ["doc_scan_kit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "doc_scan_kit",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
