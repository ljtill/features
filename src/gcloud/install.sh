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
        export URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz"
    else
        VERSION=$(echo ${VERSION} | sed 's/v//')
        export URL="https://storage.googleapis.com/cloud-sdk-release/google-cloud-cli-"${VERSION}"-linux-x86_64.tar.gz"
    fi
}

download() {
    if ! curl -sLf -o ./google-cloud-cli-linux-x86_64.tar.gz "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    tar -zxof ./google-cloud-cli-linux-x86_64.tar.gz
    mv ./google-cloud-sdk /opt/
    /opt/google-cloud-sdk/install.sh --command-completion true --path-update true --quiet
}

echo "Activating feature 'gcloud'"

version
download
install
