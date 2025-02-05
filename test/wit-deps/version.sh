#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "whoami" whoami | grep vscode

# Options-specific tests
check "version" wit-deps --version | grep "0.5.0"

# Report result
reportResults
