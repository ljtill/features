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

check_deps curl ca-certificates jq python3

get_version() {
    VERSION="${VERSION:-latest}"

    if [ "$VERSION" = "latest" ]; then
        log "INFO" "Using latest Google Cloud SDK version..."
    else
        VERSION=$(echo "$VERSION" | sed 's/v//')
        log "INFO" "Using specified version: v$VERSION"
    fi

    export VERSION
}

detect_arch() {
    log "INFO" "Detecting system architecture..."
    case "$(uname -m)" in
        x86_64 | amd64) ARCH="x86_64" ;;
        aarch64 | arm64) ARCH="arm" ;;
        *) log "ERROR" "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
    log "INFO" "Architecture detected: $ARCH"
    export ARCH
}

download_binary() {
    if [ "$VERSION" = "latest" ]; then
        URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-${ARCH}.tar.gz"
    else
        URL="https://storage.googleapis.com/cloud-sdk-release/google-cloud-cli-${VERSION}-linux-${ARCH}.tar.gz"
    fi

    log "INFO" "Downloading Google Cloud SDK from $URL"

    if ! curl -sLf --fail -o ./gcloud.tar.gz "$URL"; then
        log "ERROR" "Failed to download Google Cloud SDK!"
        exit 1
    fi

    log "INFO" "Download complete!"
}

install_binary() {
    log "INFO" "Installing Google Cloud SDK..."
    tar -zxof ./gcloud.tar.gz
    mv ./google-cloud-sdk /opt/
    /opt/google-cloud-sdk/install.sh --rc-path /etc/bash.bashrc --quiet
    log "INFO" "Google Cloud SDK installed successfully to /opt/google-cloud-sdk"
}

log "INFO" "Activating feature 'gcloud'"

get_version
detect_arch
download_binary
install_binary

log "INFO" "Installation complete!"
