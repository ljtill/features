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

version() {
    if [ "${VERSION}" = "latest" ]; then
        export VERSION=$(curl -sL https://api.github.com/repos/kubernetes-sigs/cluster-api/releases/latest | jq -r ".tag_name" | sed 's/v//')
    fi
}

download() {
    curl -Lo ./clusterctl https://github.com/kubernetes-sigs/cluster-api/releases/v$VERSION/download/clusterctl-linux-amd64
}

install() {
    chmod +x ./clusterctl
    chown root:root ./clusterctl
    mv ./clusterctl /usr/local/bin/clusterctl
}

echo "Activating feature 'clusterctl'"

version
download
install
