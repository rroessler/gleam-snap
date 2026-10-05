#!/usr/bin/env bash
set -euo pipefail

# Ensure that we have the correct argument given
if [ "$#" -eq 0 ]; then echo "Error: Missing version argument."; exit 1; fi

# Prepare the common variables to be used
GLEAM_SNAPCRAFT_FILE="snap/snapcraft.yaml"
GLEAM_SOURCE_VERSION="${1#v}"
GLEAM_SOURCE_REGEX="[0-9]+\.[0-9]+\.[0-9]+(-rc[0-9])?"

# Resolve the necessary checksums to be used now (done before replacements as a check for version release)
GLEAM_CHECKSUM_SUFFIX="unknown-linux-musl.tar.gz.sha256"
GLEAM_CHECKSUM_PREFIX="https://github.com/gleam-lang/gleam/releases/download/v"
GLEAM_CHECKSUM_AMD64=$(curl -fsSL "$GLEAM_CHECKSUM_PREFIX$GLEAM_SOURCE_VERSION/gleam-v$GLEAM_SOURCE_VERSION-x86_64-$GLEAM_CHECKSUM_SUFFIX" | awk '{print $1}')
GLEAM_CHECKSUM_ARM64=$(curl -fsSL "$GLEAM_CHECKSUM_PREFIX$GLEAM_SOURCE_VERSION/gleam-v$GLEAM_SOURCE_VERSION-aarch64-$GLEAM_CHECKSUM_SUFFIX" | awk '{print $1}')

# Attempt replacements of the current versioning
sed -i -E "s/$GLEAM_SOURCE_REGEX/$GLEAM_SOURCE_VERSION/g" $GLEAM_SNAPCRAFT_FILE

# Finally run replacements for the source checksums
sed -i -E "s/(on amd64: sha256\/)[a-z0-9]+/\1$GLEAM_CHECKSUM_AMD64/g" $GLEAM_SNAPCRAFT_FILE
sed -i -E "s/(on arm64: sha256\/)[a-z0-9]+/\1$GLEAM_CHECKSUM_ARM64/g" $GLEAM_SNAPCRAFT_FILE
