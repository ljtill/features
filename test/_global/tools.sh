#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "argocd" argocd version --client --output json
check "atlas" atlas --version
check "bicep" bicep --version
check "calicoctl" calicoctl version
check "cilium" cilium version --client
check "clusterctl" clusterctl version
check "deno" deno --version
check "flux" flux version --client --output json
check "gcloud" gcloud version
check "helm" helm version
check "istioctl" istioctl version --remote=false
check "just" just --version
check "kind" kind version
check "kubebuilder" kubebuilder version
check "kubectl" kubectl version --client=true --output=json
check "mongosh" mongosh --version
check "pkl" pkl --version
check "pulumi" pulumi version
check "redis" redis-cli --version
check "ruff" ruff --version
check "spin" spin --version
check "swift" swift --version
check "task" task --version
check "terraform" terraform -version
check "uv" uv --version
check "volta" volta --version
check "wasm-tools" wasm-tools --version
check "wasmtime" wasmtime --version
check "wit-bindgen" wit-bindgen --version
check "wit-deps" wit-deps --version
check "zig" zig version

# Report result
reportResults
