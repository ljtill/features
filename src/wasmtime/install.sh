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
        export VERSION=$(curl -sL https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r ".tag_name" | sed 's/v//')
        if [ $? -ne 0 ]; then
            echo "Version check failed"
            exit 1
        fi
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./wasmtime-v"${VERSION}"-x86_64-linux.tar.xz https://github.com/bytecodealliance/wasmtime/releases/download/v"${VERSION}"/wasmtime-v"${VERSION}"-x86_64-linux.tar.xz
    if [ $? -ne 0 ]; then
        echo "File download failed"
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
