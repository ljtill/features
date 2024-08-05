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

system() {
    export ARCHITECTURE=$(uname -m | sed 's/aarch64/arm64/')
    if [ "$ARCHITECTURE" != "amd64" ] && [ "$ARCHITECTURE" != "arm64" ]; then
        echo "Unsupported architecture: $ARCHITECTURE"
        exit 1
    fi

    export PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
    if [ "$PLATFORM" != "linux" ] && [ "$PLATFORM" != "darwin" ]; then
        echo "Unsupported platform: $PLATFORM"
        exit 1
    fi
}

version() {
    if [ "${VERSION}" = "latest" ]; then
        export VERSION=$(curl -sLf https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r ".tag_name" | sed 's/v//')
        if [ $? -ne 0 ]; then
            echo "Version check failed"
            exit 1
        fi
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -sLf -o ./argocd https://github.com/argoproj/argo-cd/releases/download/v"${VERSION}"/argocd-"${PLATFORM}"-"${ARCHITECTURE}"
    if [ $? -ne 0 ]; then
        echo "File download failed"
        exit 1
    fi
}

install() {
    chmod +x ./argocd
    chown root:root ./argocd
    mv ./argocd /usr/local/bin/argocd
}

echo "Activating feature 'argocd'"

system
version
download
install
