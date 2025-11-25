import Testing
import VendoredDocC

@Test func verifyVersionExists() async throws {
    #expect(!VendoredDocC.VendoredVersion.description.isEmpty)
    #expect(!VendoredDocC.VendoredVersion.commit.isEmpty)
}

//@Test func example() async throws {
//    let testBundle = #bundle
//    print(testBundle.bundlePath)
//}
