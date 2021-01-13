// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserReportSDK",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "UserReportSDK",
            targets: ["UserReport"]
        )
    ],
    targets: [
        .target(
            name: "UserReport",
            dependencies: [],
            path: "UserReport/UserReport",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "UserReportTests",
            dependencies: ["UserReport"],
            path: "UserReport/Tests",
            exclude: ["Info.plist"]
        )
    ]
)
