import DocCArchive
import Testing

@Test func verifyVersionExists() async throws {
  #expect(!VendoredVersion.description.isEmpty)
  #expect(!VendoredVersion.commit.isEmpty)
}
