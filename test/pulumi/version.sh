#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Feature-specific tests
check "version" pulumi version

# Options-specific tests
check "version" pulumi version | grep "3.80.0"

# Report result
reportResults