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
        export VERSION=$(curl -sLf https://api.github.com/repos/azure/bicep/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    URL="https://github.com/azure/bicep/releases/download/v"${VERSION}"/bicep-linux-x64"
    if ! curl -sLf -o ./bicep "$URL"; then
        echo "ERROR: Download failed"
        exit 1
    fi
}

install() {
    chmod +x ./bicep
    chown root:root ./bicep
    mv ./bicep /usr/local/bin/bicep
}

echo "Activating feature 'bicep'"

version
download
install
