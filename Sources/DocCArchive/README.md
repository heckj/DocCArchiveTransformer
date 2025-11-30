The data files for ingesting DocC archives source from the [DocC repository](https://github.com/swiftlang/swift-docc/) of
the [Swift Project](https://swift.org/):

```
./Sources/SwiftDocC/SwiftDocC.docc/Resources/RenderNode.spec.json
./Sources/SwiftDocC/SwiftDocC.docc/Resources/IndexingRecords.spec.json
./Sources/SwiftDocC/SwiftDocC.docc/Resources/Metadata.json
./Sources/SwiftDocC/SwiftDocC.docc/Resources/RenderIndex.spec.json
./Sources/SwiftDocC/SwiftDocC.docc/Resources/Benchmark.json
./Sources/SwiftDocC/SwiftDocC.docc/Resources/Diagnostics.json
./Sources/SwiftDocC/SwiftDocC.docc/Resources/LinkableEntities.json
./Sources/SwiftDocC/SwiftDocC.docc/Resources/ThemeSettings.spec.json
./Sources/SwiftDocC/SwiftDocC.docc/Resources/Assets.json
```

The files sourced from commit `5915e66d1eb071a4410bcf6aea0d9219a21a1f8e` on November 25, 2025
from the `main` development branch, which includes fixes for some of the JSON files.
At the time of this vendoring, the files *are not* verified or built from spec. They are updated manually,
and can include errors or mismatches to internal DocC types.

OpenAPI generator accepts a single OpenAPI spec file, so this directory merges them using
[openapi-merge-cli](https://www.npmjs.com/package/openapi-merge-cli), using the configuration file
`openapi-merge.json`:

```bash
cd Vendored
npm i openapi-merge-cli
npx openapi-merge-cli
``` 

To get Swift code for the serialized types, generate the types from the combined spec. The OpenAPI generator
is a dependency on this project, which makes the generator available for a `swift run` command:

```bash
swift run swift-openapi-generator generate --mode types \
    --access-modifier package \
    --naming-strategy idiomatic \
    --output-directory generated \
    Vendored/merged-spec.json
``` 

This is combined together in `Scripts/regenerate-types.sh` in this package.
