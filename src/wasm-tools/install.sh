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
        URL="https://api.github.com/repos/bytecodealliance/wasm-tools/releases"
        if ! curl -sLf -o ./response.json "$URL"; then
            echo "ERROR: Unable to fetch latest version"
            exit 1
        fi
        export VERSION=$(cat ./response.json | jq -r "first | .tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    URL="https://github.com/bytecodealliance/wasm-tools/releases/download/v"${VERSION}"/wasm-tools-"${VERSION}"-x86_64-linux.tar.gz"
    if ! curl -sLf -o ./wasm-tools-"${VERSION}"-x86_64-linux.tar.gz  "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    tar -zxof ./wasm-tools-"${VERSION}"-x86_64-linux.tar.gz
    chmod +x ./wasm-tools-"${VERSION}"-x86_64-linux/wasm-tools
    chown root:root ./wasm-tools-"${VERSION}"-x86_64-linux/wasm-tools
    mv ./wasm-tools-"${VERSION}"-x86_64-linux/wasm-tools /usr/local/bin/wasm-tools
}

echo "Activating feature 'wasm-tools'"

version
download
install
