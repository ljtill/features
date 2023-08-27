#!/bin/bash

set -e

ls -al "$KREW_ROOT"/bin
ls -al "$KREW_ROOT"/store/krew/
ls -al "$KREW_ROOT"/store/krew/v0.4.4/

# Import test library
source dev-container-features-test-lib

# Check the user
check "vscode" whoami | grep vscode

# Feature-specific tests
check "kubectl" kubectl version --client=true --output=json

# Options-specific tests
check "krew" kubectl krew version

# Report result
reportResults