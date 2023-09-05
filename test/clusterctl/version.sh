#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Feature-specific tests
check "version" clusterctl version

# Options-specific tests
check "version" clusterctl version | grep "1.5.1"

# Report result
reportResults