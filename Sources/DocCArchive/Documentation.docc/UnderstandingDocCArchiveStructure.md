# Understanding the structure of a DocC archive

An overview of the files and data structure that exist within a DocC archive.

## Overview

A DocC archive, at it's heart, is a directory with files at conventional locations which you can 
iteratively walk and parse. The core files of DocC - the ones that hold all the detail to be 
presented - are stored as individual JSON files in the filesystem. Some of these files only 
exist when the archive was created with explicit command-line flags.

The green check marks indicate that this library includes tests that verify the generated Swift types for the data structures parse from an example.
Following tree is a loose example structure:

```bash
ExampleDocs.doccarchive
├── assets.json (default)
├── data
│   └── documentation ✅ (default - internals are specific to the symbols provided)
│       ├── exampledocs
│       │   └── examplearticle.json ✅
│       └── exampledocs.json ✅
├── diagnostics.json ✅ (deprecated - going away in Swift 6.3)
├── index
│   └── index.json ✅ (default)
├── indexing-records.json ✅ (optional w/ --emit-digest)
├── linkable-entities.json ✅ (optional w/ --enable-experimental-external-link-support)
└── metadata.json ✅ (default)
```

The `index/index.json` is what provides the detail of what's included within the archive. In effect,
it encodes the manifest of all symbols in the archive. A DocC archive provides a JSON file, and typically an HTML page that exists to help host a single-page JavaScript application that displays the content, for each symbol.
An archive **can** incorporate more than one module (originally they were only for a single module).
The symbols within the archive are represented by "Nodes" found within the Index - a list of them.
But each node is actually a tree structure, so the list of nodes is really a list of tree data structures.

The data structures are defined in the ``VendoredDocC`` module, which has Swift types that provide the codable representations based on the OpenAPI specs that are provided within the DocC project itself.
There are some awkward spots where OpenAPI can't directly/easily represent the original type structure (specifically
around dictionaries or maps as properties on types), but otherwise maps reasonably well. The upstream
OpenAPI declarations don't, however, include any direct documentation of the types. In the sources within this
library, I've added some references to the upstream modules internal to DocC that these types represent.
