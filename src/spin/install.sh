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
        export VERSION=$(curl -sLf https://api.github.com/repos/fermyon/spin/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    URL="https://github.com/fermyon/spin/releases/download/v"${VERSION}"/spin-v"${VERSION}"-linux-amd64.tar.gz"
    if ! curl -sLf -o ./spin-linux-amd64.tar.gz "$URL"; then
        echo "ERROR: Download failed"
        exit 1
    fi
}

install() {
    tar -zxof ./spin-linux-amd64.tar.gz
    chmod +x ./spin
    chown root:root ./spin
    mv ./spin /usr/local/bin/spin
}

echo "Activating feature 'spin'"

version
download
install
