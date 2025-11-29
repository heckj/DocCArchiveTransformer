// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "DocCArchive",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "DocCArchive",
      targets: ["DocCArchive"]
    ),
    .executable(name: "splat", targets: ["ProcessArchive"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.10.0"),
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.8.0"),
    .package(url: "https://github.com/apple/swift-nio", from: "2.0.0"),
    .package(url: "https://github.com/sliemeobn/elementary.git", from: "0.3.2"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.0"),
  ],
  targets: [
    .target(
      name: "DocCArchive",
      dependencies: [
        .product(name: "Elementary", package: "elementary"),
        .product(name: "_NIOFileSystem", package: "swift-nio"),
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
      ],
      exclude: [
        "README.md",
        "Vendored/openapi-merge.json",
        "Vendored/merged-spec.json",
        "Vendored/Assets.json",
        "Vendored/RenderNode.spec.json",
        "Vendored/LinkableEntities.json",
        "Vendored/RenderIndex.spec.json",
        "Vendored/IndexingRecords.spec.json",
        "Vendored/Diagnostics.json",
        "Vendored/Metadata.json",
        "Vendored/ThemeSettings.spec.json",
        "Vendored/Benchmark.json",
      ]
    ),
    .testTarget(
      name: "DocCArchiveTests",
      dependencies: ["DocCArchive"],
      resources: [.copy("Fixtures")]
    ),
    .executableTarget(
      name: "ProcessArchive",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "_NIOFileSystem", package: "swift-nio"),
        .product(name: "Elementary", package: "elementary"),
        "DocCArchive",
      ]),
  ]
)
