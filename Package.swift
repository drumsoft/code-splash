// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "code-splash",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "code-splash",
            dependencies: []
        )
    ]
)
