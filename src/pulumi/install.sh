#!/bin/sh
set -e

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

install() {
    version=$(curl -sL https://api.github.com/repos/pulumi/pulumi/releases/latest | jq -r ".tag_name" | sed 's/v//')
    curl -Lo ./pulumi-v"$version"-linux-x64.tar.gz https://get.pulumi.com/releases/sdk/pulumi-v"$version"-linux-x64.tar.gz
    tar -zxof ./pulumi-v"$version"-linux-x64.tar.gz
    rm -f ./pulumi-v"$version"-linux-x64.tar.gz
    chmod +x ./pulumi/pulumi
    chown root:root ./pulumi/pulumi
    mv ./pulumi/pulumi /usr/local/bin/pulumi
    rm -rf ./pulumi
}

echo "Activating feature 'pulumi'"

install
