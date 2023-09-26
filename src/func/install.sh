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

check curl ca-certificates jq unzip libicu72

version() {
    if [ "${VERSION}" = "latest" ]; then
        export VERSION=$(curl -sL https://api.github.com/repos/azure/azure-functions-core-tools/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./Azure.Functions.Cli.linux-x64.zip https://github.com/azure/azure-functions-core-tools/releases/download/"${VERSION}"/Azure.Functions.Cli.linux-x64."${VERSION}".zip
}

install() {
    unzip ./Azure.Functions.Cli.linux-x64.zip -d ./azure-functions-cli
    chmod +x ./azure-functions-cli/func
    chmod +x ./azure-functions-cli/gozip
    chown -R root:root ./azure-functions-cli
    mv ./azure-functions-cli /opt
    ln -s /opt/azure-functions-cli/func /usr/local/bin/func
    ln -s /opt/azure-functions-cli/gozip /usr/local/bin/gozip
}

echo "Activating feature 'func'"

version
download
install
