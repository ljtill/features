#!/bin/sh
set -e

cd /tmp

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
    curl -Lo ./wasmtime-v"$version"-x86_64-linux.tar.xz https://github.com/bytecodealliance/wasmtime/releases/download/v"$version"/wasmtime-v"$version"-x86_64-linux.tar.xz
    xz -d ./wasmtime-v"$version"-x86_64-linux.tar.xz
    tar -xof ./wasmtime-v"$version"-x86_64-linux.tar
    rm -f ./wasmtime-v"$version"-x86_64-linux.tar
    chmod +x ./wasmtime-v"$version"-x86_64-linux/wasmtime
    chown root:root ./wasmtime-v"$version"-x86_64-linux/wasmtime
    mv ./wasmtime-v"$version"-x86_64-linux/wasmtime /usr/local/bin/wasmtime
    rm -rf ./wasmtime-v"$version"-x86_64-linux
}

echo "Activating feature 'wasmtime'"

install
