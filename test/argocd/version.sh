#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Options-specific tests
check "version" argocd version --client --output json | grep "2.8.2"

# Report result
reportResults