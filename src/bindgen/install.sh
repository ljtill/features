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
        export VERSION=$(curl -sL https://api.github.com/repos/bytecodealliance/wit-bindgen/releases/latest | jq -r ".tag_name" | cut -d'-' -f 4)
    else
        export VERSION=$(echo ${VERSION})
    fi
}

download() {
    curl -Lo ./wit-bindgen-v"${VERSION}"-x86_64-linux.tar.gz https://github.com/bytecodealliance/wit-bindgen/releases/download/wit-bindgen-cli-"${VERSION}"/wit-bindgen-v"${VERSION}"-x86_64-linux.tar.gz
}

install() {
    tar -zxof ./wit-bindgen-v"${VERSION}"-x86_64-linux.tar.gz
    chmod +x ./wit-bindgen-v"${VERSION}"-x86_64-linux/wit-bindgen
    chown root:root ./wit-bindgen-v"${VERSION}"-x86_64-linux/wit-bindgen
    mv ./wit-bindgen-v"${VERSION}"-x86_64-linux/wit-bindgen /usr/local/bin/wit-bindgen
}

echo "Activating feature 'wit-bindgen'"

version
download
install
