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

check_deps curl ca-certificates gpg pkg-config

get_version() {
    VERSION="${VERSION:-latest}"

    echo "Swift version: $VERSION"
    export VERSION
}

detect_arch() {
    echo "Detecting system architecture..."

    case "$(uname -m)" in
        x86_64 | amd64) ARCH="x86_64" ;;
        aarch64 | arm64) ARCH="aarch64" ;;
        *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    echo "Architecture detected: $ARCH"
    export ARCH
}

download_binary() {
    if [ -z "$ARCH" ]; then
        echo "Missing architecture information!"
        exit 1
    fi

    URL="https://download.swift.org/swiftly/linux/swiftly-${ARCH}.tar.gz"
    echo "Downloading Swiftly from $URL"

    if ! curl -sLf --fail -O "$URL"; then
        echo "Failed to download Swiftly!"
        exit 1
    fi

    echo "Download and extraction complete!"
}

install_binary() {
    echo "Extracting Swiftly..."
    if ! tar zxf "swiftly-${ARCH}.tar.gz"; then
        echo "Failed to extract Swiftly!"
        exit 1
    fi

    echo "Initializing Swiftly..."
    if ! ./swiftly init --no-modify-profile --skip-install --quiet-shell-followup --assume-yes; then
        echo "Failed to initialize Swiftly!"
        exit 1
    fi

    echo "Sourcing Swiftly environment"
    . "$SWIFTLY_HOME_DIR/env.sh"

    if ! swiftly install "$VERSION" --use --post-install-file "./post-install.sh" --assume-yes; then
        echo "Failed to install Swift toolchain"
        exit 1
    fi

    if [ -f ./post-install.sh ]; then
        echo "Executing post-install commands..."
        . ./post-install.sh
    fi
    
    echo "Swift installed successfully!"
}

echo "Activating feature 'swift'"

get_version
detect_arch
download_binary
install_binary

echo "Installation complete!"
