#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Options-specific tests
check "version" tofu version | grep "v1.6.0-alpha1"

# Report result
reportResults