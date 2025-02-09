#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "version" mongosh --version

# Report result
reportResults
