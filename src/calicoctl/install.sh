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
        echo "Fetching latest Calicoctl version from GitHub..."
        URL="https://api.github.com/repos/projectcalico/calico/releases/latest"

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

    URL="https://github.com/projectcalico/calico/releases/download/v${VERSION}/calicoctl-linux-${ARCH}"
    echo "Downloading Calicoctl from $URL"

    if ! curl -sLf --fail -o ./calicoctl "$URL"; then
        echo "Failed to download Calicoctl!"
        exit 1
    fi

    echo "Download complete!"
}

install_binary() {
    echo "Installing Calicoctl..."
    install -m 0755 ./calicoctl /usr/local/bin/calicoctl
    echo "Calicoctl installed successfully to /usr/local/bin/calicoctl"
}

echo "Activating feature 'calicoctl'"

get_version
detect_arch
download_binary
install_binary

echo "Installation complete!"
