#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Options-specific tests
check "wasm2js" wasm2js --version | grep "version_117"
check "wasm-as" wasm-as --version | grep "version_117"
check "wasm-ctor-eval" wasm-ctor-eval --version | grep "version_117"
check "wasm-dis" wasm-dis --version | grep "version_117"
check "wasm-emscripten-finalize" wasm-emscripten-finalize --version | grep "version_117"
check "wasm-fuzz-lattices" wasm-fuzz-lattices --version | grep "version_117"
check "wasm-fuzz-types" wasm-fuzz-types --version | grep "version_117"
check "wasm-merge" wasm-merge --version | grep "version_117"
check "wasm-metadce" wasm-metadce --version | grep "version_117"
check "wasm-opt" wasm-opt --version | grep "version_117"
check "wasm-reduce" wasm-reduce --version | grep "version_117"
check "wasm-shell" wasm-shell --version | grep "version_117"
check "wasm-split" wasm-split --version | grep "version_117"

# Report result
reportResults
