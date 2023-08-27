#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Feature-specific tests
check "kubectl" kubectl version --client=true --output=json

# Options-specific tests
check "krew" "$KREW_ROOT"/bin/kubectl-krew version

# Report result
reportResults