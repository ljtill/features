#!/bin/bash
set -e

cd "$(mktemp -d)"

log() {
    local LEVEL="$1"
    shift
    echo "[$LEVEL] $*"
}

check_deps() {
    log "INFO" "Checking required dependencies: $*"
    export DEBIAN_FRONTEND=noninteractive

    if ! dpkg -s "$@" > /dev/null 2>&1; then
        if [ ! -f /var/lib/apt/lists/lock ]; then
            log "INFO" "Running apt update..."
            apt update -y
        fi
        log "INFO" "Installing missing dependencies: $*"
        apt -y install --no-install-recommends "$@"
    else
        log "INFO" "All required dependencies are already installed."
    fi
}

check_deps curl ca-certificates gpg pkg-config

get_version() {
    VERSION="${VERSION:-latest}"

    log "INFO" "Swift version: $VERSION"
    export VERSION
}

detect_arch() {
    log "INFO" "Detecting system architecture..."

    case "$(uname -m)" in
        x86_64 | amd64) ARCH="x86_64" ;;
        aarch64 | arm64) ARCH="aarch64" ;;
        *) log "ERROR" "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    log "INFO" "Architecture detected: $ARCH"
    export ARCH
}

download_binary() {
    if [ -z "$ARCH" ]; then
        log "ERROR" "Missing architecture information!"
        exit 1
    fi

    URL="https://download.swift.org/swiftly/linux/swiftly-${ARCH}.tar.gz"
    log "INFO" "Downloading Swiftly from $URL"

    if ! curl -sLf --fail -O "$URL"; then
        log "ERROR" "Failed to download Swiftly!"
        exit 1
    fi

    log "INFO" "Download and extraction complete!"
}

install_binary() {
    log "INFO" "Extracting Swiftly..."
    if ! tar zxf "swiftly-${ARCH}.tar.gz"; then
        log "ERROR" "Failed to extract Swiftly!"
        exit 1
    fi

    log "INFO" "Initializing Swiftly..."
    if ! ./swiftly init --no-modify-profile --skip-install --quiet-shell-followup --assume-yes; then
        log "ERROR" "Failed to initialize Swiftly!"
        exit 1
    fi

    log "INFO" "Sourcing Swiftly environment"
    . "$SWIFTLY_HOME_DIR/env.sh"

    if ! swiftly install "$VERSION" --use --post-install-file "./post-install.sh" --assume-yes; then
        log "ERROR" "Failed to install Swift toolchain"
        exit 1
    fi

    if [ -f ./post-install.sh ]; then
        log "INFO" "Executing post-install commands..."
        . ./post-install.sh
    fi
    
    log "INFO" "Swift installed successfully!"
}

log "INFO" "Activating feature 'swift'"

get_version
detect_arch
download_binary
install_binary

log "INFO" "Installation complete!"
