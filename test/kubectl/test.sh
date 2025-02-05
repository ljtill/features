#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "version" kubectl version --client=true --output=json

# Report result
reportResults
