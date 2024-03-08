#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "wasm2c" wasm2c --version
check "wasm2wat" wasm2wat --version
check "wasm-decompile" wasm-decompile --version
check "wasm-interp" wasm-interp --version
check "wasm-objdump" wasm-objdump --version
check "wasm-stats" wasm-stats --version
check "wasm-strip" wasm-strip --version
check "wasm-validate" wasm-validate --version
check "wast2json" wast2json --version
check "wat2wasm" wat2wasm --version
check "wat-desugar" wat-desugar --version

# Report result
reportResults
