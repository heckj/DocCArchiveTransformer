// The Swift Programming Language
// https://docs.swift.org/swift-book

import VendoredDocC

let metadata = Components.Schemas.Metadata(
  bundleDisplayName: "fred", bundleIdentifier: "org.swift",
  schemaVersion: .init(major: 1, minor: 0, patch: 0))

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
