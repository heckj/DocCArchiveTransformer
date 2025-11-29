import Foundation
import Testing
import VendoredDocC

@testable import DocCArchive

// I don't have a test fixture that uses `--enable-inherited-docs` - and
// I don't think any detail about the fact that docs were or weren't inherited
// are included within the archive data.

// likewise, I'm not sure if the protection level for a symbol is included or not.

// --include-extended-types / --exclude-extended-types
// --experimental-skip-synthesized-symbols - determines at symbol-graph generation
// time if the symbols are included or not. DocC doesn't care.

//   --enable-inherited-docs Inherit documentation for inherited symbols
// --enable-experimental-external-link-support
//                        Support external links to this documentation output.
//      Write additional link metadata files to the output directory to support
//      resolving documentation links to the documentation in that output
//      directory.
// --enable-experimental-overloaded-symbol-presentation
//                        Collects all the symbols that are overloads of each
//                        other onto a new merged-symbol page.
// --enable-mentioned-in/--disable-mentioned-in
//                        Render a section on symbol documentation which links
//                        to articles that mention that symbol (default:
//                        --enable-mentioned-in)
@Test func testParsingMetadata() async throws {
  let exampleFixture = try #require(TestFixtures.exampleDocs)
  let exampleArchive = Archive(path: exampleFixture.path)
  let metadata = try exampleArchive.parseMetadata()
  #expect(metadata.bundleDisplayName == "ExampleDocs")
  print(metadata)

  let sampleFixture = try #require(TestFixtures.sampleLibrary)
  let sampleArchive = Archive(path: sampleFixture.path)
  let sampleMetadata = try sampleArchive.parseMetadata()
  #expect(sampleMetadata.bundleDisplayName == "SampleLibrary")
  print(sampleMetadata)
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
  print(exampleIndexingRecords)
  #expect(exampleIndexingRecords.count == 2)
  for r in exampleIndexingRecords {
    print("kind: \(r.kind.rawValue)")
    print("location: \(r.location)")
    print("title: \(r.title)")
    print("summary: \(r.summary)")
    print("headings: \(r.headings)")
    print("indexable content: \(r.rawIndexableTextContent)")
    print("platforms: \(String(describing: r.platforms))")
  }

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
      // path, in this case, appears to be the path under the `data` directory to the JSON
      // data file that's represented by a RenderNode
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
