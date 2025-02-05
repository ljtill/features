#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Check the user
check "whoami" whoami | grep vscode

# Options-specific tests
check "version" calicoctl version | grep "3.29.1"

# Report result
reportResults
