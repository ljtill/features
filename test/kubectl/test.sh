#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "version" kubectl version --client=true --output=json

# Options-specific tests
check "kubelogin" kubelogin --version

# Report result
reportResults
