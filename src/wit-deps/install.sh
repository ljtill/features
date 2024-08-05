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
        export VERSION=$(curl -sLf https://api.github.com/repos/bytecodealliance/wit-deps/releases/latest | jq -r ".tag_name" | cut -d'-' -f 4 | sed 's/v//')
        if [ $? -ne 0 ]; then
            echo "Version check failed"
            exit 1
        fi
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    URL="https://github.com/bytecodealliance/wit-deps/releases/download/v"${VERSION}"/wit-deps-x86_64-unknown-linux-musl"
    if ! curl -sLf -o ./wit-deps-x86_64-unknown-linux-musl "$URL"; then
        echo "ERROR: Download failed"
        exit 1
    fi
}

install() {
    chmod +x ./wit-deps-x86_64-unknown-linux-musl
    chown root:root ./wit-deps-x86_64-unknown-linux-musl
    mv ./wit-deps-x86_64-unknown-linux-musl /usr/local/bin/wit-deps
}

echo "Activating feature 'wit-deps'"

version
download
install
