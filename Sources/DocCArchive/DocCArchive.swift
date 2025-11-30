import AsyncAlgorithms
import Elementary
import Foundation
import NIOCore  // experiment - ByteBuffer
import NIOFileSystem  // experiment - NIOFilesystem

// Elementary
struct Thing: HTML {
  var body: some HTML {

  }
}

func run() async throws {
  var fred = Thing().renderFormatted()  //debugging pretty output
  fred = Thing().render()  //regular output
  // I think elementary could be used to render(info:) a stream writer that spools out something
  // through NIOFilesystem - using the same path that is used in Vapor to write to the socket
  // as it rolls (speedier)
}

public struct Archive {
  /// File path to the DocC Archive
  public let baseArchivePath: String

  // change to URL - and track "filesystem" vs. "internet" URL for retrieving JSON files?
  public init(path: String) {
    self.baseArchivePath = path
  }

  let decoder = JSONDecoder()
  // TODO(PERF): maybe allow this to be provided - use alternate decoders (Ikagi, swift-extras, etc) if
  // needed for better performance?

  // TODO(PERF): Use NIO Filesystem data loading - async/await alternate to Foundation's Data(contentsOf:)
  func loadFile() async throws -> ByteBuffer {
    let path = FilePath(baseArchivePath + "metadata")
    let data = try await ByteBuffer(contentsOf: path, maximumSizeAllowed: .megabytes(1))
    return data
  }

  func parseMetadata() throws -> Components.Schemas.Metadata {
    let metadataURL = URL(filePath: baseArchivePath).appending(component: "metadata")
      .appendingPathExtension(
        "json")
    // print("metadata URL calculated at \(metadataURL.path)")

    let metadataBytes = try Data(contentsOf: metadataURL)
    let metadata = try decoder.decode(Components.Schemas.Metadata.self, from: metadataBytes)
    return metadata
  }

  func parseDiagnostics() throws -> Components.Schemas.Diagnostics {
    let diagnosticsURL = URL(filePath: baseArchivePath).appending(component: "diagnostics")
      .appendingPathExtension("json")

    let diagnosticsBytes = try Data(contentsOf: diagnosticsURL)
    let diagnostics = try decoder.decode(
      Components.Schemas.Diagnostics.self, from: diagnosticsBytes)
    return diagnostics
  }

  // full text index records - only available when the docc archive was
  // created with `--emit-digest`
  func parseIndexingRecords() throws -> Components.Schemas.IndexingRecords {
    let indexingRecordsURL = URL(filePath: baseArchivePath).appending(component: "indexing-records")
      .appendingPathExtension("json")

    let indexingRecordsBytes = try Data(contentsOf: indexingRecordsURL)
    let indexingRecords = try decoder.decode(
      Components.Schemas.IndexingRecords.self, from: indexingRecordsBytes)
    return indexingRecords
  }

  // always available for the static hosting scenarios, which is default.
  func parseIndex() throws -> Components.Schemas.RenderIndex {
    let indexURL = URL(filePath: baseArchivePath).appending(component: "index").appending(
      component: "index"
    )
    .appendingPathExtension("json")

    let indexBytes = try Data(contentsOf: indexURL)
    let index = try decoder.decode(Components.Schemas.RenderIndex.self, from: indexBytes)
    return index
  }

  func parseRenderNode(dataPath: String) throws -> Components.Schemas.RenderNode {
    let nodeURL = URL(filePath: baseArchivePath).appending(component: "data").appending(
      component: dataPath
    )
    .appendingPathExtension("json")

    let nodeBytes = try Data(contentsOf: nodeURL)
    let index = try decoder.decode(Components.Schemas.RenderNode.self, from: nodeBytes)
    return index
  }

  // recursive depth-first walk of tree of Nodes through the list provided, doing the
  // function stuff on each node (visitor pattern). Not sure I care about the level
  // beyond pretty printing, but leaving it in for now...
  func walkRenderIndexNodes(
    nodes: [Components.Schemas.Node], doing: (Components.Schemas.Node, Int) throws -> Void
  ) throws {
    for node in nodes {
      try walkRenderIndexNodes(node: node, level: 0, doing: doing)
    }
  }

  func walkRenderIndexNodes(
    node: Components.Schemas.Node, level: Int, doing: (Components.Schemas.Node, Int) throws -> Void
  ) throws {
    try doing(node, level)
    if let childNodes = node.children {
      for n in childNodes {
        try walkRenderIndexNodes(node: n, level: level + 1, doing: doing)
      }
    }
  }

  // only available when the archive was generated with the experimental linkable entities enabled
  // This holds - or could hold - almost everything from the --emit-digest and quite a bit more, enabling
  // easier references to content external to the DocC archive. Symbols include the usr (mangled name)
  // and reference URL is on each, using the `doc://MODULENAME/documentatiopn/MODULENAME` custom URL structure.
  func parseLinkableEntities() throws -> Components.Schemas.LinkableEntities {
    let linkableEntitiesURL = URL(filePath: baseArchivePath).appending(
      component: "linkable-entities"
    )
    .appendingPathExtension("json")

    let linkableEntitiesBytes = try Data(contentsOf: linkableEntitiesURL)
    let linkDestinations = try decoder.decode(
      Components.Schemas.LinkableEntities.self, from: linkableEntitiesBytes)
    return linkDestinations
  }

  public func convert() throws {
    // To walk an archive:
    // open and parse the index (all into memory)
    // index.interfaceLanguages -> .additionalProperties -> ["swift"] => [Nodes]
    // [Nodes] is actually a list of tree structure Enums that you walk
    let index = try self.parseIndex()

    // index.includedArchiveIdentifiers is a list of the module names included in this archive.

    let index_interface_languages = index.interfaceLanguages
    // interfaceLanguages is a map of `String : [Node]` where the
    // string is a language provided, and the list of nodes are the nodes
    // for that language.
    // The "additionalProperties" name of this is an artifact of how
    // OpenAPI Spec gets rendered into Swift types. The upstream type
    // that matches this (https://github.com/swiftlang/swift-docc/blob/main/Sources/SwiftDocC/Indexing/RenderIndexJSON/RenderIndex.swift#L24)
    // has a property that's the map. Guessing openAPI doesn't do a great
    // job of representing a dictionary other than treating it like a full JSON
    // object.

    // proper iteration would be to get the keys of `additionalProperties`
    // and iterate through the whole key set.
    if let listOfRenderNodes: [Components.Schemas.Node] =
      index_interface_languages.additionalProperties["swift"]
    {

      // walk through the tree of nodes, opening path (if available, not all have paths).
      // the path is the JSON location to the RenderNode, so open & parse that - and then do
      // whatever transformation you want from there.
      try self.walkRenderIndexNodes(
        nodes: listOfRenderNodes,
        doing: { visitedNode, level in
          if let renderNodePath = visitedNode.path {
            let _ = try self.parseRenderNode(dataPath: renderNodePath)
            print("RenderNode (\(visitedNode.title) at \(renderNodePath) parsed")
          } else {
            print("Node title \(visitedNode.title) at level \(level) doesn't have a path")
          }
        }
      )
    }
  }

  // This is going to be tricky - mostly getting the right understanding of what's sendable, isolated, etc - in order to provide access to the channel. Classic Swift advice says to serialize this to something like MainActor

  //  /// provide access to an AsyncChannel of strings that make up the transformed content
  //  public func withChunks(t: Transformer, s: ChunkStrategy, processChunk: nonisolated(nonsending) (AsyncChannel<String>) async -> ()) async throws {
  //
  //    // create an AsyncStream and present it to the processChunk closure to provide access to it
  //    let channel = AsyncChannel<String>()
  //
  ////    Task {
  ////    print("Consumer Task: Waiting for messages...")
  ////    for await message in channel {
  ////        print("Consumer Task: Received -> \(message)")
  ////    }
  ////    print("Consumer Task: Channel closed. Exiting.")
  ////    }
  //    // consuming the channel
  //    try await withThrowingDiscardingTaskGroup { group in
  //      group.addTask {
  //        await processChunk(channel)
  //      }
  //    }
  //
  //    // 3. Task B: The producer (sender)
  //    // This task sends messages and then finishes the channel.
  //    Task {
  //        print("Producer Task: Sending 'Hello'...")
  //        await channel.send("Hello") // send will suspend until a receiver is ready
  //
  //        print("Producer Task: Sending 'World'...")
  //        await channel.send("World")
  //
  //        print("Producer Task: Finishing channel...")
  //        // Calling finish() signals the end of the sequence to the consumer task.
  //        channel.finish()
  //    }
  //
  //  }

}

/// The strategy for converting the tree of nodes into sequences that get rendered into contiguous, static content
public enum ChunkStrategy {
  /// One big file with everything in it
  case one
  /// DocC classic - every file gets its own chunk of data
  case everySymbol
  /// Slightly optimized from DocC classic - properties, methods, etc on a type are collapsed into the page for the type.
  case collapsedToType
}

public struct Transformer {
  func convert(node: Components.Schemas.RenderNode) async throws -> String {
    // this may need access to look up/load other nodes for their content...
    return ""
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
