# DocCArchiveTransformer

The data files for ingesting DocC archives source from the 
[DocC repository](https://github.com/swiftlang/swift-docc/) of the [Swift Project](https://swift.org/).
Read through [the vendored README](Sources/VendoredDocC/README.md) for details on how it was assembled
and turned into Swift types.  

The test fixtures were generated from [heckj/example-docc-project](https://github.com/heckj/example-docc-project),
creating DocC Archives and zipping them to use within this repository. 
The commands used to generate the two archives:

```bash
swift package --disable-sandbox generate-documentation --target ExampleDocs --emit-digest
swift package --disable-sandbox generate-documentation --target SampleLibrary --emit-digest
```
