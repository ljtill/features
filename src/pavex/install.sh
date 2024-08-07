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
        URL="https://api.github.com/repos/LukeMathWalker/pavex/releases/latest"
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
    URL="https://github.com/LukeMathWalker/pavex/releases/download/"${VERSION}"/pavex_cli-x86_64-unknown-linux-gnu.tar.xz"
    if ! curl -sLf -o ./pavex_cli-x86_64-unknown-linux-gnu.tar.xz "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    xz -d ./pavex_cli-x86_64-unknown-linux-gnu.tar.xz
    tar -xof ./pavex_cli-x86_64-unknown-linux-gnu.tar
    chmod +x ./pavex_cli-x86_64-unknown-linux-gnu/pavex
    chown root:root ./pavex_cli-x86_64-unknown-linux-gnu/pavex
    mv ./pavex_cli-x86_64-unknown-linux-gnu/pavex /usr/local/bin/pavex
}

echo "Activating feature 'pavex'"

version
download
install
