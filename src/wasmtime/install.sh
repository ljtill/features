#!/bin/sh
set -e

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

install() {
    version=$(curl -sL https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r ".tag_name" | sed 's/v//')
    curl -Lo ./wasmtime-x86_64-linux.tar.xz https://github.com/bytecodealliance/wasmtime/releases/download/v"$version"/wasmtime-v"$version"-x86_64-linux.tar.xz
    xz -d ./wasmtime-x86_64-linux.tar.xz
    tar -xof ./wasmtime-x86_64-linux.tar
    rm -f ./wasmtime-x86_64-linux.tar
    chmod +x ./wasmtime-x86_64-linux/wasmtime
    chown root:root ./wasmtime-x86_64-linux/wasmtime
    mv ./wasmtime-x86_64-linux/wasmtime /usr/local/bin/wasmtime
    rm -rf ./wasmtime-x86_64-linux
}

echo "Activating feature 'wasmtime'"

install
