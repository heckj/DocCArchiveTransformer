# DocCArchive

> NOTE: This isn't the same code as Helge's lovely 
> [DocCArchive library](https://github.com/DoccZz/DocCArchive), which he built
> and maintains by hand. It serves loosely the same purpose, but is independently
> created based on OpenAPI data declarations provided from 
> [Swift's DocC](https://github.com/swiftlang/swift-docc/).

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

## Locally testing on Linux:

```bash
rm -rf .build
container run -it -c 4 -m 8g -v "$(pwd):/src" -w src/ swift:6.2 swift test
```
