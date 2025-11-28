import Foundation
internal import VendoredDocC

public struct Archive {
  /// File path to the DocC Archive
  public let path: String

  public init(path: String) {
    self.path = path
  }

  // ExampleDocs.doccarchive
  // ├── assets.json
  // ├── data
  // │   └── documentation
  // │       ├── exampledocs
  // │       │   └── examplearticle.json
  // │       └── exampledocs.json
  // ├── diagnostics.json ✅ (need an fixture that includes diagnostics)
  // ├── index
  // │   └── index.json
  // ├── indexing-records.json ✅ (full text search content)
  // ├── linkable-entities.json
  // └── metadata.json ✅

  let decoder = JSONDecoder()

  func parseMetadata() throws -> Components.Schemas.Metadata {
    let metadataURL = URL(filePath: path).appending(component: "metadata").appendingPathExtension(
      "json")
    print("metadata URL calculated at \(metadataURL.path)")

    let metadataBytes = try Data(contentsOf: metadataURL)
    let metadata = try decoder.decode(Components.Schemas.Metadata.self, from: metadataBytes)
    return metadata
  }

  func parseDiagnostics() throws -> Components.Schemas.Diagnostics {
    let diagnosticsURL = URL(filePath: path).appending(component: "diagnostics")
      .appendingPathExtension("json")

    let diagnosticsBytes = try Data(contentsOf: diagnosticsURL)
    let diagnostics = try decoder.decode(
      Components.Schemas.Diagnostics.self, from: diagnosticsBytes)
    return diagnostics
  }

  func parseIndexingRecords() throws -> Components.Schemas.IndexingRecords {
    let indexingRecordsURL = URL(filePath: path).appending(component: "indexing-records")
      .appendingPathExtension("json")

    let indexingRecordsBytes = try Data(contentsOf: indexingRecordsURL)
    let indexingRecords = try decoder.decode(
      Components.Schemas.IndexingRecords.self, from: indexingRecordsBytes)
    return indexingRecords
  }

  func parseIndex() throws -> Components.Schemas.RenderIndex {
    let indexURL = URL(filePath: path).appending(component: "index").appending(component: "index")
      .appendingPathExtension("json")

    let indexBytes = try Data(contentsOf: indexURL)
    let index = try decoder.decode(Components.Schemas.RenderIndex.self, from: indexBytes)
    return index
  }

  // recursive depth-first walk of tree of Nodes through the list provided, doing the
  // function stuff on each node (visitor pattern)
  func walkRenderIndexNodes(
    nodes: [Components.Schemas.Node], doing: (Components.Schemas.Node, Int) -> Void
  ) {
    for node in nodes {
      walkRenderIndexNodes(node: node, level: 0, doing: doing)
    }
  }

  func walkRenderIndexNodes(
    node: Components.Schemas.Node, level: Int, doing: (Components.Schemas.Node, Int) -> Void
  ) {
    doing(node, level)
    if let childNodes = node.children {
      for n in childNodes {
        walkRenderIndexNodes(node: n, level: level + 1, doing: doing)
      }
    }
  }
}

// JSON files to parse within a DocC Archive:
//
// ExampleDocs.doccarchive
// ├── assets.json
// ├── data
// │   └── documentation
// │       ├── exampledocs
// │       │   └── examplearticle.json
// │       └── exampledocs.json
// ├── diagnostics.json
// ├── index
// │   ├── availability.index
// │   ├── data.mdb
// │   ├── index.json
// │   └── navigator.index
// ├── indexing-records.json
// ├── linkable-entities.json
// └── metadata.json
//
// SampleLibrary.doccarchive
// ├── assets.json
// ├── data
// │   └── documentation
// │       ├── samplelibrary
// │       │   ├── sampleactor
// │       │   │   ├── actor-implementations.json
// │       │   │   ├── assertisolated(_:file:line:).json
// │       │   │   ├── assumeisolated(_:file:line:).json
// │       │   │   ├── getstate(forkey:).json
// │       │   │   ├── preconditionisolated(_:file:line:).json
// │       │   │   └── updatestate(forkey:value:).json
// │       │   ├── sampleactor.json
// │       │   ├── sampleclass
// │       │   │   ├── init(name:isactive:).json
// │       │   │   ├── isactive.json
// │       │   │   ├── name.json
// │       │   │   └── toggleactive().json
// │       │   ├── sampleclass.json
// │       │   ├── sampleerror
// │       │   │   ├── computationfailed(reason:).json
// │       │   │   ├── error-implementations.json
// │       │   │   ├── invalidcount.json
// │       │   │   └── localizeddescription.json
// │       │   ├── sampleerror.json
// │       │   ├── samplestruct
// │       │   │   ├── count.json
// │       │   │   ├── customstringconvertible-implementations.json
// │       │   │   ├── description.json
// │       │   │   ├── id.json
// │       │   │   ├── init(count:score:).json
// │       │   │   ├── samplemethod().json
// │       │   │   └── score.json
// │       │   └── samplestruct.json
// │       └── samplelibrary.json
// ├── diagnostics.json
// ├── index
// │   ├── availability.index
// │   ├── data.mdb
// │   ├── index.json
// │   └── navigator.index
// ├── index.html
// ├── indexing-records.json
// ├── linkable-entities.json
// └── metadata.json
