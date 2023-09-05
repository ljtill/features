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
    tag_name=$(curl -sL https://api.github.com/repos/fluxcd/flux2/releases/latest | jq -r ".tag_name" | sed 's/v//')
    if [ "${VERSION}" = "latest" ]; then
        curl -Lo ./flux_linux_amd64.tar.gz https://github.com/fluxcd/flux2/releases/download/v"$tag_name"/flux_"$tag_name"_linux_amd64.tar.gz
    else
        curl -Lo ./flux_linux_amd64.tar.gz https://github.com/fluxcd/flux2/releases/download/v"$VERSION"/flux_"$VERSION"_linux_amd64.tar.gz
    fi
}

install() {
    tar -zxof ./flux_linux_amd64.tar.gz
    chmod +x ./flux
    chown root:root ./flux
    mv ./flux /usr/local/bin/flux
}

echo "Activating feature 'flux'"

download
install
