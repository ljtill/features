#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "wasm2js" --version
check "wasm-as" --version
check "wasm-ctor-eval" --version
check "wasm-dis" --version
check "wasm-emscripten-finalize" --version
check "wasm-fuzz-lattices" --version
check "wasm-fuzz-types" --version
check "wasm-merge" --version
check "wasm-metadce" --version
check "wasm-opt" --version
check "wasm-reduce" --version
check "wasm-shell" --version
check "wasm-split" --version

# Report result
reportResults
