#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "whoami" whoami | grep vscode

# Options-specific tests
check "version" istioctl version --remote=false | grep "1.24.2"

# Report result
reportResults
