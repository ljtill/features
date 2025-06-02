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

check_deps curl ca-certificates jq git unzip

get_version() {
    VERSION="${VERSION:-latest}"

    if [ "$VERSION" = "latest" ]; then
        echo "Fetching latest Kubectl version..."
        URL="https://dl.k8s.io/release/stable.txt"

        if ! curl -sLf --fail -o ./response.txt "$URL"; then
            echo "Unable to fetch latest version from Kubernetes releases!"
            exit 1
        fi

        VERSION=$(cat ./response.txt | sed 's/v//')
        echo "Latest version found: v$VERSION"
    else
        VERSION=$(echo "$VERSION" | sed 's/v//')
        echo "Using specified version: v$VERSION"
    fi

    export VERSION
}

detect_arch() {
    echo "Detecting system architecture..."
    case "$(uname -m)" in
        x86_64 | amd64) ARCH="amd64" ;;
        aarch64 | arm64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
    echo "Architecture detected: $ARCH"
    export ARCH
}

download_binary() {
    if [ -z "$VERSION" ]; then
        echo "Missing version information!"
        exit 1
    fi

    URL="https://dl.k8s.io/release/v${VERSION}/bin/linux/${ARCH}/kubectl"
    echo "Downloading Kubectl from $URL"

    if ! curl -sLf --fail -o ./kubectl "$URL"; then
        echo "Failed to download Kubectl!"
        exit 1
    fi

    echo "Download complete!"
}

install_binary() {
    echo "Installing Kubectl..."
    install -m 0755 ./kubectl /usr/local/bin/kubectl
    echo "Kubectl installed successfully to /usr/local/bin/kubectl"
}

echo "Activating feature 'kubectl'"

get_version
detect_arch
download_binary
install_binary

echo "Installation complete!"
