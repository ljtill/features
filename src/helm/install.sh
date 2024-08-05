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
        RESPONSE=$(curl -sL -w "%{http_code}" https://api.github.com/repos/helm/helm/releases/latest | sed 's/v//')
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
   RESPONSE=$(curl -sL -w "%{http_code}" -o ./helm-linux-amd64.tar.gz https://get.helm.sh/helm-v"${VERSION}"-linux-amd64.tar.gz)
    HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

    if [ "$HTTP_STATUS" -ne 200 ]; then
        echo "Failed to download file"
        exit 1
    fi
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
