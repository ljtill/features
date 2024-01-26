#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "version" zig version

# Report result
reportResults
