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

check curl ca-certificates jq git

version() {
    if [ "${VERSION}" = "latest" ]; then
        URL="https://dl.k8s.io/release/stable.txt"
        if ! curl -sLf -o ./response.json "$URL"; then
            echo "ERROR: Unable to fetch latest version"
            exit 1
        fi
        export VERSION=$(cat ./response.json | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    URL="https://dl.k8s.io/release/v"${VERSION}"/bin/linux/amd64/kubectl"
    if ! curl -sLf -o ./kubectl "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    chmod +x ./kubectl
    chown root:root ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
}

options() {
    if [ "${KUBELOGIN}" = "true" ]; then
        URL="https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip"
        if ! curl -sLf -o ./kubelogin-linux-amd64.zip "$URL"; then
        echo "ERROR: Unable to download file"
            exit 1
        fi
        
        unzip ./kubelogin-linux-amd64.zip
        chmod +x ./bin/linux_amd64/kubelogin
        chown root:root ./bin/linux_amd64/kubelogin
        mv ./bin/linux_amd64/kubelogin /usr/local/bin/kubelogin
    fi
}

echo "Activating feature 'kubectl'"

version
download
install
options
