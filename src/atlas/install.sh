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
        echo "Fetching latest MongoDB Atlas CLI version from GitHub..."
        URL="https://api.github.com/repos/mongodb/mongodb-atlas-cli/releases/latest"

        if ! curl -sLf --fail -o ./response.json "$URL"; then
            echo "Unable to fetch latest version from GitHub API!"
            exit 1
        fi

        VERSION=$(jq -r '.tag_name | sub("atlascli/v"; "")' < ./response.json)
        echo "Latest version found: v$VERSION"
    else
        VERSION=$(echo "$VERSION" | sed 's/v//')
        echo "Using specified version: v$VERSION"
    fi

    export VERSION
}

detect_arch() {
    echo "Detecting system architecture..."
    ARCH="$(dpkg --print-architecture)"

    case "$(uname -m)" in
        x86_64 | amd64) ARCH="x86_64" ;;
        aarch64 | arm64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    echo "Architecture detected: $ARCH"
    export ARCH
}

download_binary() {
    if [ -z "$VERSION" ] || [ -z "$ARCH" ]; then
        echo "Missing version or architecture information!"
        exit 1
    fi

    URL="https://github.com/mongodb/mongodb-atlas-cli/releases/download/atlascli%2Fv${VERSION}/mongodb-atlas-cli_${VERSION}_linux_${ARCH}.tar.gz"

    echo "Downloading MongoDB Atlas CLI from $URL"

    if ! curl -sLf --fail -o ./mongodb.tar.gz "$URL"; then
        echo "Failed to download MongoDB Atlas CLI!"
        exit 1
    fi

    echo "Download complete!"
}

install_binary() {
    echo "Installing MongoDB Atlas CLI..."
    tar -zxof ./mongodb.tar.gz
    install -m 0755 ./mongodb-atlas-cli_${VERSION}_linux_${ARCH}/bin/atlas /usr/local/bin/atlas
    echo "MongoDB Atlas CLI installed successfully to /usr/bin/atlas"
}

echo "Activating feature 'atlas'"

get_version
detect_arch
download_binary
install_binary

echo "Installation complete!"
