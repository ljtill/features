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
        URL="https://api.github.com/repos/FiloSottile/mkcert/releases/latest"
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
    URL="https://github.com/FiloSottile/mkcert/releases/download/v"${VERSION}"/mkcert-v"${VERSION}"-linux-amd64"
    if ! curl -sLf -o ./mkcert-v"${VERSION}"-linux-amd64 "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    chmod +x ./mkcert-v"${VERSION}"-linux-amd64
    chown root:root ./mkcert-v"${VERSION}"-linux-amd64
    mv ./mkcert-v"${VERSION}"-linux-amd64 /usr/local/bin/mkcert
}

echo "Activating feature 'mkcert'"

version
download
install
