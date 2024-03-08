#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Options-specific tests
check "wasm2c" wasm2c --version | grep "1.0.34"
check "wasm2wat" wasm2wat --version | grep "1.0.34"
check "wasm-decompile" wasm-decompile --version | grep "1.0.34"
check "wasm-interp" wasm-interp --version | grep "1.0.34"
check "wasm-objdump" wasm-objdump --version | grep "1.0.34"
check "wasm-stats" wasm-stats --version | grep "1.0.34"
check "wasm-strip" wasm-strip --version | grep "1.0.34"
check "wasm-validate" wasm-validate --version | grep "1.0.34"
check "wast2json" wast2json --version | grep "1.0.34"
check "wat2wasm" wat2wasm --version | grep "1.0.34"
check "wat-desugar" wat-desugar --version | grep "1.0.34"

# Report result
reportResults
