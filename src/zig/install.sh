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
        URL="https://api.github.com/repos/ziglang/zig/releases/latest"
        if ! curl -sLf -o ./response.json "$URL"; then
            echo "ERROR: Unable to fetch latest version"
            exit 1
        fi
        export VERSION=$(cat ./response.json | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    URL="https://ziglang.org/download/"${VERSION}"/zig-linux-x86_64-"${VERSION}".tar.xz"
    if ! curl -sLf -o ./zig-linux-x86_64-"${VERSION}".tar.xz "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    xz -d ./zig-linux-x86_64-"${VERSION}".tar.xz
    tar -xof ./zig-linux-x86_64-"${VERSION}".tar
    chmod +x ./zig-linux-x86_64-"${VERSION}"/zig
    chown root:root ./zig-linux-x86_64-"${VERSION}"/zig
    mv ./zig-linux-x86_64-"${VERSION}"/zig /usr/local/bin/zig
}

echo "Activating feature 'zig'"

version
download
install
