#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "version" pf --version
check "version" pfazure --version

# Report result
reportResults
