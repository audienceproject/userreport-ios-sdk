// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserReport",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "UserReport",
            targets: ["UserReportSDK"]
        )
    ],
    targets: [
        .target(
            name: "UserReportSDK",
            dependencies: [],
            path: "UserReport/UserReport",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "UserReportTests",
            dependencies: ["UserReportSDK"],
            path: "UserReport/Tests",
            exclude: ["Info.plist"]
        )
    ]
)
