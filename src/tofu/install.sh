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

check curl ca-certificates jq unzip

version() {
    if [ "${VERSION}" = "latest" ]; then
        export VERSION=$(curl -sL https://api.github.com/repos/opentofu/opentofu/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./tofu_linux_amd64.zip https://github.com/opentofu/opentofu/releases/download/v"${VERSION}"/tofu_"${VERSION}"_linux_amd64.zip
}

install() {
    unzip ./tofu_linux_amd64.zip -d ./tofu_linux_amd64
    chmod +x ./tofu_linux_amd64/tofu
    chown root:root ./tofu_linux_amd64
    mv ./tofu_linux_amd64/tofu /usr/local/bin/tofu
}

echo "Activating feature 'tofu'"

version
download
install
