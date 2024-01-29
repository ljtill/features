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

check curl ca-certificates jq

version() {
    if [ "${VERSION}" = "latest" ]; then
        export VERSION=$(curl -sL https://api.github.com/repos/cilium/cilium-cli/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./cilium-linux-amd64.tar.gz https://github.com/cilium/cilium-cli/releases/download/v"${VERSION}"/cilium-linux-amd64.tar.gz
}

install() {
    tar -zxof ./cilium-linux-amd64.tar.gz
    chmod +x ./cilium
    chown root:root ./cilium
    mv ./cilium /usr/local/bin/cilium
}

echo "Activating feature 'cilium'"

version
download
install
