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
    tag_name=$(curl -sL https://api.github.com/repos/pulumi/pulumi/releases/latest | jq -r ".tag_name" | sed 's/v//')
    if [ "${VERSION}" = "latest" ]; then
        curl -Lo ./pulumi-linux-x64.tar.gz https://get.pulumi.com/releases/sdk/pulumi-v"$tag_name"-linux-x64.tar.gz
    else
        curl -Lo ./pulumi-linux-x64.tar.gz https://get.pulumi.com/releases/sdk/pulumi-v"$VERSION"-linux-x64.tar.gz
    fi
}

install() {
    tar -zxof ./pulumi-linux-x64.tar.gz
    chmod +x ./pulumi/pulumi
    chown root:root ./pulumi/pulumi
    mv ./pulumi/pulumi /usr/local/bin/pulumi
}

echo "Activating feature 'pulumi'"

download
install
