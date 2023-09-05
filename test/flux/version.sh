#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Feature-specific tests
check "version" flux version --client --output json

# Options-specific tests
check "version" flux version --client --output json | grep "2.1.0"

# Report result
reportResults