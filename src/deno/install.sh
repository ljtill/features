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

check curl ca-certificates jq unzip

version() {
    if [ "${VERSION}" = "latest" ]; then
        URL="https://api.github.com/repos/denoland/deno/releases/latest"
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
    URL="https://github.com/denoland/deno/releases/download/v"${VERSION}"/deno-x86_64-unknown-linux-gnu.zip"
    if ! curl -sLf -o ./deno-x86_64-unknown-linux-gnu.zip "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    unzip ./deno-x86_64-unknown-linux-gnu.zip
    chmod +x ./deno
    chown root:root ./deno
    mv ./deno /usr/local/bin/deno
}

echo "Activating feature 'deno'"

version
download
install
