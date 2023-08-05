#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "version" argocd version --client --output json
check "version" clusterctl version
check "version" flux version --client --output json
check "version" helm version
check "version" kind version
check "version" kubebuilder version
check "version" kubectl version --client=true --output=json
check "version" pulumi version
check "version" slight version
check "version" spin --version
check "version" wasmtime --version

# Report result
reportResults
