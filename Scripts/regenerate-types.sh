#!/usr/bin/env bash
set -eou pipefail

# see https://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
THIS_SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo $THIS_SCRIPT_DIR # /Users/heckj/src/DocCArchive/Scripts

cd ${THIS_SCRIPT_DIR}/../Sources/DocCArchive/Vendored
npm i openapi-merge-cli
npx openapi-merge-cli

cd ${THIS_SCRIPT_DIR}/..
swift run swift-openapi-generator generate --mode types \
    --access-modifier package \
    --naming-strategy idiomatic \
    --output-directory Sources/DocCArchive/generated \
    Sources/DocCArchive/Vendored/merged-spec.json
