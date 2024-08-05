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
    echo "Checking system..."
    local ARCHITECTURE=$(uname -m | tr '[:upper:]' '[:lower:]')
    local PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')

    case "$ARCHITECTURE" in
        x86_64) ARCHITECTURE="amd64" ;;
        aarch64) ARCHITECTURE="arm64" ;;
        *)
            echo "Unsupported architecture: $ARCHITECTURE"
            exit 1
            ;;
    esac

    case "$PLATFORM" in
        linux | darwin) ;;
        *)
            echo "Unsupported platform: $PLATFORM"
            exit 1
            ;;
    esac

    export $PLATFORM
    export $ARCHITECTURE
}

version() {
    echo "Retrieving version..."
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
    echo "Downloading binary..."
    STATUS=$(curl -L -w %{http_code} https://github.com/argoproj/argo-cd/releases/download/v"${VERSION}"/argocd-"${PLATFORM}"-"${ARCHITECTURE}" > ./argocd)
    if [ "${STATUS}" -ne 200 ]; then
        echo "File download failed"
        exit 1
    fi
}

install() {
    echo "Installing binary..."
    chmod +x ./argocd
    chown root:root ./argocd
    mv ./argocd /usr/local/bin/argocd
}

echo "Activating feature 'argocd'"

system
version
download
install
