// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CrashMonitor",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "CrashMonitor",
            targets: ["CrashMonitor"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kstenerud/KSCrash.git", .upToNextMajor(from: "2.0.0-rc.8")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CrashMonitor",
            dependencies: [
                "CrashMonitorObjC",
                .product(name: "Filters", package: "KSCrash"),
                .product(name: "Recording", package: "KSCrash"),
                .product(name: "Installations", package: "KSCrash"),
            ],
            path: "Sources/CrashMonitor",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "CrashMonitorObjC",
            dependencies: [
                .product(name: "Recording", package: "KSCrash"),
            ],
            path: "Sources/CrashMonitorObjC",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")],
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "CrashMonitorTests",
            dependencies: ["CrashMonitor"]
        ),
    ]
)
