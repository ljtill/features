#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

export KREW_ROOT="/usr/local/krew"
export PATH="${KREW_ROOT}/bin:${PATH}"

# Check the user
check "vscode" whoami | grep vscode

# Feature-specific tests
check "kubectl" kubectl version --client=true --output=json

# Options-specific tests
check "krew" kubectl krew version

# Report result
reportResults