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
    ARCHITECTURE=$(uname -m | tr '[:upper:]' '[:lower:]')
    PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')

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
    TEMP_FILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }
    trap 'rm -f "$TEMP_FILE"' EXIT

    URL="https://github.com/argoproj/argo-cd/releases/download/v${VERSION}/argocd-${PLATFORM}-${ARCHITECTURE}"
    echo "URL: $URL"
    
    if curl -s -L -f -o "$TEMP_FILE" "$URL"; then
        mv "$TEMP_FILE" ./argocd || { echo "File rename failed"; exit 1; }
    else
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
