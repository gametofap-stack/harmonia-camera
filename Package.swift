// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Harmonia",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "HarmoniaCore",
            targets: ["HarmoniaCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HarmoniaCore",
            dependencies: [],
            path: "Harmonia"
        )
    ]
)
