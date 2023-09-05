#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Options-specific tests
check "version" kubectl version --client=true --output=json | grep "1.28.1"

# Report result
reportResults