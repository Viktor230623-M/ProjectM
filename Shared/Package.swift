// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ProjectMShared",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(name: "ProjectMShared", targets: ["ProjectMShared"])
    ],
    targets: [
        .target(name: "ProjectMShared", path: "Sources/ProjectMShared")
    ]
)
