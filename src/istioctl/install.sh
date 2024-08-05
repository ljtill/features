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
        export VERSION=$(curl -sLf https://api.github.com/repos/istio/istio/releases/latest | jq -r ".tag_name" | sed 's/v//')
        if [ $? -ne 0 ]; then
            echo "Version check failed"
            exit 1
        fi
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -sLf -o ./istioctl-linux-amd64.tar.gz https://github.com/istio/istio/releases/download/"${VERSION}"/istioctl-"${VERSION}"-linux-amd64.tar.gz
    if [ $? -ne 0 ]; then
        echo "File download failed"
        exit 1
    fi
}

install() {
    tar -zxof ./istioctl-linux-amd64.tar.gz
    chmod +x ./istioctl
    chown root:root ./istioctl
    mv ./istioctl /usr/local/bin/istioctl
}

echo "Activating feature 'istioctl'"

version
download
install
