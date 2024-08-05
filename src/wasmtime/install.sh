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

check curl ca-certificates jq xz-utils

version() {
    if [ "${VERSION}" = "latest" ]; then
        export VERSION=$(curl -sLf https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    URL="https://github.com/bytecodealliance/wasmtime/releases/download/v"${VERSION}"/wasmtime-v"${VERSION}"-x86_64-linux.tar.xz"
    if ! curl -sLf -o ./wasmtime-v"${VERSION}"-x86_64-linux.tar.xz "$URL"; then
        echo "ERROR: Download failed"
        exit 1
    fi
}

install() {
    xz -d ./wasmtime-v"${VERSION}"-x86_64-linux.tar.xz
    tar -xof ./wasmtime-v"${VERSION}"-x86_64-linux.tar
    chmod +x ./wasmtime-v"${VERSION}"-x86_64-linux/wasmtime
    chown root:root ./wasmtime-v"${VERSION}"-x86_64-linux/wasmtime
    mv ./wasmtime-v"${VERSION}"-x86_64-linux/wasmtime /usr/local/bin/wasmtime
}

echo "Activating feature 'wasmtime'"

version
download
install
