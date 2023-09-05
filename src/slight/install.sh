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

download() {
    tag_name=$(curl -sL https://api.github.com/repos/deislabs/spiderlightning/releases | jq -r "first | .tag_name" | sed 's/v//')
    if [ "${VERSION}" = "latest" ]; then
        curl -Lo ./slight-linux-x86_64.tar.gz https://github.com/deislabs/spiderlightning/releases/download/v"$tag_name"/slight-linux-x86_64.tar.gz
    else
        curl -Lo ./slight-linux-x86_64.tar.gz https://github.com/deislabs/spiderlightning/releases/download/v"$VERSION"/slight-linux-x86_64.tar.gz
    fi
}

install() {
    tar -zxof ./slight-linux-x86_64.tar.gz
    chmod +x ./release/slight
    chown root:root ./release/slight
    mv ./release/slight /usr/local/bin/slight
}

echo "Activating feature 'slight'"

download
install
