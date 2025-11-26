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
  let interface_languages: Components.Schemas.RenderIndex.InterfaceLanguagesPayload = exampleIndex
    .interfaceLanguages

  #expect(interface_languages.additionalProperties.count == 1)
  let nodes: [Components.Schemas.Node] = try #require(
    interface_languages.additionalProperties["swift"])
  let topNode = nodes[0]

  print("type: \(topNode._type)")
  print("title: \(topNode.title)")
  print("path: \(topNode.path)")
  print("beta: \(topNode.beta)")
  print("deprecated: \(topNode.deprecated)")
  print("icon: \(topNode.icon)")
  print("external: \(topNode.external)")
  print("children: \(topNode.children)")

  // this is where all the indexed content is -
  // referenced by path, type, and title, with each node potentiall having a list of children.

  let sampleFixture = try #require(TestFixtures.sampleLibrary)
  let sampleArchive = Archive(path: sampleFixture.path)
  let sampleIndex = try sampleArchive.parseIndex()
  //print(sampleIndex)
  #expect(sampleIndex.includedArchiveIdentifiers.count == 1)
  #expect(sampleIndex.includedArchiveIdentifiers[0] == "SampleLibrary")
}
