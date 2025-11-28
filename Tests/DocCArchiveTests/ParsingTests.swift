import Foundation
import Testing
import VendoredDocC

@testable import DocCArchive

@Test func testParsingMetadata() async throws {
  let exampleFixture = try #require(TestFixtures.exampleDocs)
  let exampleArchive = Archive(path: exampleFixture.path)
  let metadata = try exampleArchive.parseMetadata()
  #expect(metadata.bundleDisplayName == "ExampleDocs")

  let sampleFixture = try #require(TestFixtures.sampleLibrary)
  let sampleArchive = Archive(path: sampleFixture.path)
  let sampleMetadata = try sampleArchive.parseMetadata()
  #expect(sampleMetadata.bundleDisplayName == "SampleLibrary")
}

@Test func testParsingDiagnostics() async throws {
  let exampleFixture = try #require(TestFixtures.exampleDocs)
  let exampleArchive = Archive(path: exampleFixture.path)
  let exampleDiagnostics = try exampleArchive.parseDiagnostics()
  #expect(exampleDiagnostics.isEmpty)
  let sampleFixture = try #require(TestFixtures.sampleLibrary)
  let sampleArchive = Archive(path: sampleFixture.path)
  let sampleDiagnostics = try sampleArchive.parseDiagnostics()
  #expect(sampleDiagnostics.isEmpty)
}

@Test func testParsingIndexingRecords() async throws {
  let exampleFixture = try #require(TestFixtures.exampleDocs)
  let exampleArchive = Archive(path: exampleFixture.path)
  let exampleIndexingRecords = try exampleArchive.parseIndexingRecords()
  //print(exampleIndexingRecords)
  #expect(exampleIndexingRecords.count == 2)

  let sampleFixture = try #require(TestFixtures.sampleLibrary)
  let sampleArchive = Archive(path: sampleFixture.path)
  let sampleIndexingRecords = try sampleArchive.parseIndexingRecords()
  //print(sampleIndexingRecords)
  #expect(sampleIndexingRecords.count == 26)
}

@Test func testParsingRenderIndex() async throws {
  let exampleFixture = try #require(TestFixtures.exampleDocs)
  let exampleArchive = Archive(path: exampleFixture.path)
  let exampleIndex = try exampleArchive.parseIndex()

  #expect(exampleIndex.includedArchiveIdentifiers.count == 1)
  #expect(exampleIndex.includedArchiveIdentifiers[0] == "ExampleDocs")
  let exampleIndex_interface_languages = exampleIndex.interfaceLanguages

  #expect(exampleIndex_interface_languages.additionalProperties.count == 1)
  let exampleDocsNodes: [Components.Schemas.Node] = try #require(
    exampleIndex_interface_languages.additionalProperties["swift"])

  exampleArchive.walkRenderIndexNodes(
    nodes: exampleDocsNodes,
    doing: { visitedNode, level in
      let indent = String(repeating: "  ", count: level)
      if let nodeType = visitedNode._type {
        print("\(indent)[\(level)] type: \(nodeType.rawValue), title: \(visitedNode.title)")
      } else {
        print("\(indent)[\(level)] type: ?, title: \(visitedNode.title)")
      }
      print("\(indent)    path: \(visitedNode.path ?? "")")
      print(
        "\(indent)    beta: \(visitedNode.beta ?? false), deprecated: \(visitedNode.deprecated ?? false), external: \(visitedNode.external ?? false), icon: \(visitedNode.icon ?? "-none-")"
      )
    }
  )

  // this is where all the indexed content is -
  // referenced by path, type, and title, with each node potentially having a list of children.

  let sampleFixture = try #require(TestFixtures.sampleLibrary)
  let sampleArchive = Archive(path: sampleFixture.path)
  let sampleIndex = try sampleArchive.parseIndex()
  print(sampleIndex)
  #expect(sampleIndex.includedArchiveIdentifiers.count == 1)
  #expect(sampleIndex.includedArchiveIdentifiers[0] == "SampleLibrary")

  let sampleIndex_interface_languages = sampleIndex.interfaceLanguages

  #expect(sampleIndex_interface_languages.additionalProperties.count == 1)
  let sampleLibraryNodes: [Components.Schemas.Node] = try #require(
    sampleIndex_interface_languages.additionalProperties["swift"])

  sampleArchive.walkRenderIndexNodes(
    nodes: sampleLibraryNodes,
    doing: { visitedNode, level in
      let indent = String(repeating: "  ", count: level)
      if let nodeType = visitedNode._type {
        print("\(indent)[\(level)] type: \(nodeType.rawValue), title: \(visitedNode.title)")
      } else {
        print("\(indent)[\(level)] type: ?, title: \(visitedNode.title)")
      }
      print("\(indent)    path: \(visitedNode.path ?? "")")
      print(
        "\(indent)    beta: \(visitedNode.beta ?? false), deprecated: \(visitedNode.deprecated ?? false), external: \(visitedNode.external ?? false), icon: \(visitedNode.icon ?? "-none-")"
      )
    }
  )
}
