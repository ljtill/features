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
        RESPONSE=$(curl -sL -w "%{http_code}" https://api.github.com/repos/pulumi/pulumi/releases/latest | sed 's/v//')
        HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
        
        if [ "$HTTP_STATUS" -eq 200 ]; then
            export VERSION=$(echo "$RESPONSE" | sed '$d' | jq -r ".tag_name")
        else
            echo "Failed to fetch the latest version."
            exit 1
        fi
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    RESPONSE=$(curl -sL -w "%{http_code}" -o ./pulumi-linux-x64.tar.gz https://get.pulumi.com/releases/sdk/pulumi-v"${VERSION}"-linux-x64.tar.gz)
    HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

    if [ "$HTTP_STATUS" -ne 200 ]; then
        echo "Failed to download file"
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
