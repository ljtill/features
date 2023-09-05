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

download() {
    tag_name=$(curl -sL https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r ".tag_name" | sed 's/v//')
    if [ "${VERSION}" = "latest" ]; then
        curl -Lo ./wasmtime-x86_64-linux.tar.xz https://github.com/bytecodealliance/wasmtime/releases/latest/download/wasmtime-v"$tag_name"-x86_64-linux.tar.xz
    else
        curl -Lo ./wasmtime-x86_64-linux.tar.xz https://github.com/bytecodealliance/wasmtime/releases/download/v"$version"/wasmtime-v"$version"-x86_64-linux.tar.xz
    fi
}

install() {
    xz -d ./wasmtime-x86_64-linux.tar.xz
    tar -xof ./wasmtime-x86_64-linux.tar
    chmod +x ./wasmtime-x86_64-linux/wasmtime
    chown root:root ./wasmtime-x86_64-linux/wasmtime
    mv ./wasmtime-x86_64-linux/wasmtime /usr/local/bin/wasmtime
}

echo "Activating feature 'wasmtime'"

download
install
