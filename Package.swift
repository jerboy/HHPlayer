// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HHPlayer",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "HHPlayer",
            targets: ["HHPlayer"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "HHPlayer",
            url: "https://github.com/jerboy/HHPlayer/releases/download/spm-master/HHPlayer.xcframework.zip",
            checksum: "c5ac026768b997b86ca330df5e8e216deb17c20e5f2547be0dd1f3e5065f9dff"
        ),
    ]
)
