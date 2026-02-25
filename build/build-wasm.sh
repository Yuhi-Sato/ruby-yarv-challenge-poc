#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

BASE_WASM="../node_modules/@ruby/4.0-wasm-wasi/dist/ruby+stdlib.wasm"

bundle install

YRUBY_LIB=$(bundle exec ruby -e 'puts Gem::Specification.find_by_name("yruby").gem_dir + "/lib"')

rbwasm pack \
  "$BASE_WASM" \
  --dir "${YRUBY_LIB}::/usr/local/lib/ruby/yruby" \
  -o ../public/ruby+yruby.wasm

echo "Built: public/ruby+yruby.wasm"
ls -lh ../public/ruby+yruby.wasm
