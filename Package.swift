// swift-tools-version: 5.9
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
            name: "CrashMonitorCore",
            targets: ["CrashMonitorCore"]
        ),
        .library(
            name: "CrashMonitorInstall",
            targets: ["CrashMonitorInstall"]
        ),
        .library(
            name: "CrashMonitorReports",
            targets: ["CrashMonitorReports"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kstenerud/KSCrash.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "CrashMonitorCore",
            dependencies: [
                .product(name: "Recording", package: "KSCrash"),
            ],
            path: "Sources/CrashMonitorCore",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "CrashMonitorInstall",
            dependencies: [
                "CrashMonitorCore",
                .product(name: "Recording", package: "KSCrash"),
                .product(name: "Installations", package: "KSCrash"),
            ],
            path: "Sources/CrashMonitorInstall",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "CrashMonitorReports",
            dependencies: [
                "CrashMonitorCore",
                "CrashMonitorObjC",
                .product(name: "Recording", package: "KSCrash"),
                .product(name: "Filters", package: "KSCrash"),
            ],
            path: "Sources/CrashMonitorReports",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "CrashMonitorObjC",
            dependencies: [
                .product(name: "Recording", package: "KSCrash"),
                .product(name: "Filters", package: "KSCrash"),
            ],
            path: "Sources/CrashMonitorObjC",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")],
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "CrashMonitorTests",
            dependencies: [
                "CrashMonitorCore",
                "CrashMonitorInstall",
                "CrashMonitorReports",
            ]
        ),
    ]
)
