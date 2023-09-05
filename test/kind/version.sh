#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Feature-specific tests
check "version" kind version

# Options-specific tests
check "version" kind version | grep "0.20.0"

# Report result
reportResults