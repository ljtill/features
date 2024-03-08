#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "wasm2js" wasm2js --version
check "wasm-as" wasm-as --version
check "wasm-ctor-eval" wasm-ctor-eval --version
check "wasm-dis" wasm-dis --version
check "wasm-emscripten-finalize" wasm-emscripten-finalize --version
check "wasm-fuzz-lattices" wasm-fuzz-lattices --version
check "wasm-fuzz-types" wasm-fuzz-types --version
check "wasm-merge" wasm-merge --version
check "wasm-metadce" wasm-metadce --version
check "wasm-opt" wasm-opt --version
check "wasm-reduce" wasm-reduce --version
check "wasm-shell" wasm-shell --version
check "wasm-split" wasm-split --version

# Report result
reportResults
