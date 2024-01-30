#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "version" argocd version --client --output json
check "version" bicep --version
check "version" wit-bindgen --version
check "version" calicoctl version
check "version" cilium version --client
check "version" clusterctl version
check "version" flux version --client --output json
check "version" func version
check "version" helm version
check "version" istioctl version --remote=false
check "version" kind version
check "version" kubebuilder version
check "version" kubectl version --client=true --output=json
check "version" pulumi version
check "version" rad version
check "version" slight --version
check "version" spin --version
check "version" tofu version
check "version" wasmtime --version
check "version" zig version

# Report result
reportResults
