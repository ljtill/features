#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Feature-specific tests
check "version" slight --version

# Options-specific tests
check "version" slight --version | grep "0.5.1"

# Report result
reportResults