#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Options-specific tests
check "version" wit-bindgen --version | grep "0.16.0"

# Report result
reportResults