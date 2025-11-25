// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "DocCArchiveTransformer",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "DocCArchiveTransformer",
      targets: ["DocCArchiveTransformer"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.10.0"),
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.8.0"),
  ],
  targets: [
    .target(
      name: "DocCArchiveTransformer",
      dependencies: ["VendoredDocC"]
    ),
    .target(
      name: "VendoredDocC",
      dependencies: [.product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")],
      exclude: [
        "openapi-merge.json",
        "Assets.json",
        "README.md",
        "RenderNode.spec.json",
        "merged-spec.json",
        "LinkableEntities.json",
        "RenderIndex.spec.json",
        "IndexingRecords.spec.json",
        "Diagnostics.json",
        "Metadata.json",
        "ThemeSettings.spec.json",
        "Benchmark.json"
      ]
    ),
    .testTarget(
      name: "DocCArchiveTransformerTests",
      dependencies: ["DocCArchiveTransformer"],
      resources: [.copy("Fixtures")]
    ),
  ]
)
