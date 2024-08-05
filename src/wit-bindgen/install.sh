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
        RESPONSE=$(curl -sL -w "%{http_code}" https://api.github.com/repos/bytecodealliance/wit-bindgen/releases/latest)
        HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
        
        if [ "$HTTP_STATUS" -eq 200 ]; then
            export VERSION=$(echo "$RESPONSE" | sed '$d' | jq -r ".tag_name" | sed 's/v//')

        else
            echo "Failed to fetch the latest version."
            exit 1
        fi
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    RESPONSE=$(curl -sL -w "%{http_code}" -o ./wit-bindgen-v"${VERSION}"-x86_64-linux.tar.gz https://github.com/bytecodealliance/wit-bindgen/releases/download/v"${VERSION}"/wit-bindgen-"${VERSION}"-x86_64-linux.tar.gz)
    HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

    if [ "$HTTP_STATUS" -ne 200 ]; then
        echo "Failed to download file"
        exit 1
    fi
}

install() {
    tar -zxof ./wit-bindgen-v"${VERSION}"-x86_64-linux.tar.gz
    chmod +x ./wit-bindgen-"${VERSION}"-x86_64-linux/wit-bindgen
    chown root:root ./wit-bindgen-"${VERSION}"-x86_64-linux/wit-bindgen
    mv ./wit-bindgen-"${VERSION}"-x86_64-linux/wit-bindgen /usr/local/bin/wit-bindgen
}

echo "Activating feature 'wit-bindgen'"

version
download
install
