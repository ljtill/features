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

check_deps curl ca-certificates jq

get_version() {
    VERSION="${VERSION:-latest}"

    if [ "$VERSION" = "latest" ]; then
        echo "Fetching latest Pulumi version from GitHub..."
        URL="https://api.github.com/repos/pulumi/pulumi/releases/latest"

        if ! curl -sLf --fail -o ./response.json "$URL"; then
            echo "Unable to fetch latest version from GitHub API!"
            exit 1
        fi

        VERSION=$(jq -r ".tag_name" < ./response.json | sed 's/v//')
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
        x86_64 | amd64) ARCH="x64" ;;
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

    URL="https://get.pulumi.com/releases/sdk/pulumi-v${VERSION}-linux-${ARCH}.tar.gz"
    echo "Downloading Pulumi from $URL"

    if ! curl -sLf --fail -o ./pulumi.tar.gz "$URL"; then
        echo "Failed to download Pulumi!"
        exit 1
    fi

    echo "Download complete!"
}

install_binary() {
    echo "Installing Pulumi..."
    tar -zxof ./pulumi.tar.gz
    chmod +x ./pulumi/pulumi
    chown -R root:root ./pulumi/
    mv ./pulumi/* /usr/local/bin/
    echo "Pulumi installed successfully to /usr/local/bin/"
}

echo "Activating feature 'pulumi'"

get_version
detect_arch
download_binary
install_binary

echo "Installation complete!"
