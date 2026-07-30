// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "ISBNKit",
  platforms: [
    .iOS(.v15),
    .watchOS(.v8),
    .macOS(.v12),
    .tvOS(.v15),
    .visionOS(.v1)
  ],
  products: [
    .library(name: "ISBNKit", targets: ["ISBNKit"]),
  ],
  targets: [
    .target(name: "ISBNKit"),
    .testTarget(
      name: "ISBNKitTests",
      dependencies: ["ISBNKit"]),
  ],
  swiftLanguageModes: [.v6])

if Context.environment["SPI_BUILD"] != nil {
  package.dependencies.append(
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.5"))
}
