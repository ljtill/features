#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "argocd" argocd version --client --output json
check "bicep" bicep --version
check "calicoctl" calicoctl version
check "cilium" cilium version --client
check "clusterctl" clusterctl version
check "flux" flux version --client --output json
check "func" func version
check "helm" helm version
check "istioctl" istioctl version --remote=false
check "kind" kind version
check "kubebuilder" kubebuilder version
check "kubectl" kubectl version --client=true --output=json
check "pulumi" pulumi version
check "rad" rad version
check "slight" slight --version
check "spin" spin --version
check "tofu" tofu version
check "wasm-tools" wasm-tools --version
check "wasmtime" wasmtime --version
check "wit-bindgen" wit-bindgen --version
check "zig" zig version

# Report result
reportResults
