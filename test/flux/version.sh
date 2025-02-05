#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "whoami" whoami | grep vscode

# Options-specific tests
check "version" flux version --client --output json | grep "2.4.0"

# Report result
reportResults
