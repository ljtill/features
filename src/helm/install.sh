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
        export VERSION=$(curl -sL https://api.github.com/repos/helm/helm/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./helm-linux-amd64.tar.gz https://get.helm.sh/helm-v"${VERSION}"-linux-amd64.tar.gz
}

install() {
    tar -zxof ./helm-linux-amd64.tar.gz
    chmod +x ./linux-amd64/helm
    chown root:root ./linux-amd64/helm
    mv ./linux-amd64/helm /usr/local/bin/helm
    rm -rf ./linux-amd64
}

echo "Activating feature 'helm'"

version
download
install
