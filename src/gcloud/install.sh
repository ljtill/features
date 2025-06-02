#!/bin/bash
set -e

cd "$(mktemp -d)"

check_deps() {
    echo "Checking required dependencies: $*"
    export DEBIAN_FRONTEND=noninteractive

    if ! dpkg -s "$@" > /dev/null 2>&1; then
        if [ ! -f /var/lib/apt/lists/lock ]; then
            echo "Running apt update..."
            apt update -y
        fi
        echo "Installing missing dependencies: $*"
        apt -y install --no-install-recommends "$@"
    else
        echo "All required dependencies are already installed."
    fi
}

check_deps curl ca-certificates jq python3

get_version() {
    VERSION="${VERSION:-latest}"

    if [ "$VERSION" = "latest" ]; then
        echo "Using latest Google Cloud SDK version..."
    else
        VERSION=$(echo "$VERSION" | sed 's/v//')
        echo "Using specified version: v$VERSION"
    fi

    export VERSION
}

detect_arch() {
    echo "Detecting system architecture..."
    case "$(uname -m)" in
        x86_64 | amd64) ARCH="x86_64" ;;
        aarch64 | arm64) ARCH="arm" ;;
        *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
    echo "Architecture detected: $ARCH"
    export ARCH
}

download_binary() {
    if [ "$VERSION" = "latest" ]; then
        URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-${ARCH}.tar.gz"
    else
        URL="https://storage.googleapis.com/cloud-sdk-release/google-cloud-cli-${VERSION}-linux-${ARCH}.tar.gz"
    fi

    echo "Downloading Google Cloud SDK from $URL"

    if ! curl -sLf --fail -o ./gcloud.tar.gz "$URL"; then
        echo "Failed to download Google Cloud SDK!"
        exit 1
    fi

    echo "Download complete!"
}

install_binary() {
    echo "Installing Google Cloud SDK..."
    tar -zxof ./gcloud.tar.gz
    mv ./google-cloud-sdk /opt/
    /opt/google-cloud-sdk/install.sh --rc-path /etc/bash.bashrc --quiet
    echo "Google Cloud SDK installed successfully to /opt/google-cloud-sdk"
}

echo "Activating feature 'gcloud'"

get_version
detect_arch
download_binary
install_binary

echo "Installation complete!"
