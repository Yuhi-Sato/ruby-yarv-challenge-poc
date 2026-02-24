#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# Base wasm from npm package
BASE_WASM="../node_modules/@ruby/4.0-wasm-wasi/dist/ruby+stdlib.wasm"

# Path inside WASM VFS where the gem directory will be mounted.
# Ruby's GEM_PATH will be set to this value at runtime.
WASM_GEM_PATH="/usr/local/bundle"

if [ -n "${GEM_PATH:-}" ]; then
  # Use the gem directory specified by the GEM_PATH environment variable.
  # Expected to be a single directory containing gems/ and specifications/.
  SOURCE_GEM_PATH="$GEM_PATH"
  echo "Using GEM_PATH from environment: ${SOURCE_GEM_PATH}"
else
  # Fall back to installing gems locally via Bundler and auto-detecting the path.
  bundle install
  SOURCE_GEM_PATH=$(bundle exec ruby -e 'require "bundler"; puts Bundler.bundle_path')
  echo "Using Bundler-managed gem path: ${SOURCE_GEM_PATH}"
fi

# Pack the full gem directory (gems/ + specifications/) into the WASM VFS.
# At runtime, Ruby's GEM_PATH is pointed to WASM_GEM_PATH so gems are
# discoverable through the normal gem system without $LOAD_PATH hacks.
rbwasm pack \
  "$BASE_WASM" \
  --dir "${SOURCE_GEM_PATH}::${WASM_GEM_PATH}" \
  -o ../public/ruby+yruby.wasm

echo "Built: public/ruby+yruby.wasm"
echo "  Source : ${SOURCE_GEM_PATH}"
echo "  WASM   : ${WASM_GEM_PATH}"
ls -lh ../public/ruby+yruby.wasm
