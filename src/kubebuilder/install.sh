#!/bin/sh
set -e

cd "$(mktemp -d)"

check() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt update..."
            apt update -y
        fi
        apt -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

check curl ca-certificates

download() {
    if [ "${VERSION}" = "latest" ]; then
        curl -Lo ./kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/latest/download/kubebuilder_linux_amd64
    else
        curl -Lo ./kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/v$VERSION/download/kubebuilder_linux_amd64
    fi
}

install() {
    chmod +x ./kubebuilder
    chown root:root ./kubebuilder
    mv ./kubebuilder /usr/local/bin/kubebuilder
}

echo "Activating feature 'kubebuilder'"

download
install
