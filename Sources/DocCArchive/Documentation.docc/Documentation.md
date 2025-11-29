# ``DocCArchive``

A library to load and process DocC archives.

## Overview

This library (and executable) exists to read DocC Archives and iterate through the contents of the archive, transforming it into another set of files, with varying format. 
A goal is to support reading files either locally on disk, or remotely from URL locations if they are hosted and available.
My primary goal is to generate a single large HTML, a few large HTML files, several markdown files, or even an ePub document - all of which are static content and don't require JavaScript to present it.

The use cases I've run into that I'd like this to support:

- Render an archive out to flat, static HTML that doesn't require JavaScript to present, and with a simpler URL structure than DocC provides today, and that doesn't use `:` in the file names to enable easier Windows and cross-platform support to viewing the documentation from an archive.
- Render each symbol into a markdown file that you could ingest into a Vector Database to support LLM based interactions - answering questions, agentic coding, etc.
- Render an archive into an ePub for transfer offline viewing without a hosting setup.

The internal structure of a DocC archive is a tree of "nodes", with each node represented within an index, and the data for each node maintained separately in a file.
Read <doc:UnderstandingDocCArchiveStructure> for a full description of the data structures.

### API DevNotes

What's the API I want to expose here?

Does Archive accept closures that give access to the parsed content types vended from VendoredDocC
or does it hide all that and just give you a "write this to HTML", "epub", "markdown", etc.
Do I want to provide something async here that uses NIOFileSystem (or remote data requests) to get
ByteBuffers and parse the JSON from them, invoked as needed while "walking" a DocC Archive?

I could also extend the VendoredDocC types and provide implementation wrappers to do the walking.

I guess at a high level, I'd like to be able to invoke a CLI that reads a DocC archive
(locally, maybe accessible over the internet through HTTP/HTTPS), and writes out (STDOUT? or to a file)
the resulting combined HTML content.

There's a variation of this, generating snippet sections by "page" from the markdown that might make a
lot more sense for a RAG/semantic embedding index to the content, if that was being stored in a
Vector database for retrieval and processing. In that version, I'd want each of the chunks to be broken
up into smaller retrievable segments, not one giant "monster" doc - so something that dumps out a
sequence (async channel?) of markdown content would make sense. That would be more of a library/embedded
thing though - but returning an async stream (channel?) of blobs of data that I could just deal with
one after the other to combine into a single HTML, or deal with smaller segments at a time, could be nice.

So - expose a async stream of some kind - async Channel enables some support of back-pressure, which is
generally a good idea.

How to wrangle the "raw data type" into "something useful" transformation (markdown, html, etc)?

option 1 - hand in a closure that exposes the raw data types from VendoredDocC and you have your way,
returning whatever you want.
option 2 - I expose a protocol that you conform to, and take that in as a generic "consumer" of the types
that processes the data into something concrete. Then you hand that to the archive when you're either
initializing the darned thing, or when you initiate the stream output.
option 3 - I don't make that exposed at all, I just "do it" and take responsibility for the markdown
or HTML output doing whatever it is I'd like.

output flows:
- chunks of HTML
- chunks of Markdown
- one big HTML
- one big Markdown
? do I want to control the level of granularity here? For example, everything below the top node is a
"chapter" for an ePub document, and those are generated independently? Or maybe types and their properties
are combined into a single output, but each type gets their own "chunk" - and each article, and maybe each
step of a tutorial?



Swift Vector Database that works with MLX: https://github.com/rryam/VecturaKit
Embeddings w/ MLTensor: https://github.com/jkrukowski/swift-embeddings

## Topics

