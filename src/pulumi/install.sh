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
        export VERSION=$(curl -sLf https://api.github.com/repos/pulumi/pulumi/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    URL="https://get.pulumi.com/releases/sdk/pulumi-v"${VERSION}"-linux-x64.tar.gz"
    if ! curl -sLf -o ./pulumi-linux-x64.tar.gz "$URL"; then
        echo "ERROR: Download failed"
        exit 1
    fi
}

install() {
    tar -zxof ./pulumi-linux-x64.tar.gz
    chmod +x ./pulumi/pulumi
    chown root:root ./pulumi/pulumi
    mv ./pulumi/pulumi /usr/local/bin/pulumi
}

echo "Activating feature 'pulumi'"

version
download
install
