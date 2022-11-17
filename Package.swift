// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "fltrUI",
    platforms: [ .iOS(.v14) ],
    products: [
        .library(name: "fltrUI",
                 targets: [ "fltrUI" ]),
        .library(name: "HapticsSound",
                 targets: [ "HapticsSound" ]),
        .library(name: "Orientation",
                 targets: [ "Orientation" ]),
        .library(name: "QrReader",
                 targets: ["QrReader"])    ],
    dependencies: [
    ],
    targets: [
        .target(name: "fltrUI",
                dependencies: [ "Orientation",
                                "QrReader",
                                "HapticsSound", ]),
        .target(name: "HapticsSound",
                dependencies: []),
        .target(name: "Orientation",
                dependencies: []),
        .target(
            name: "QrReader",
            dependencies: [ "Orientation",
                            "HapticsSound" ]),
    ]
)
