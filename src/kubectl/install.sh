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

check_deps curl ca-certificates jq git unzip

get_version() {
    VERSION="${VERSION:-latest}"

    if [ "$VERSION" = "latest" ]; then
        log "INFO" "Fetching latest Kubectl version..."
        URL="https://dl.k8s.io/release/stable.txt"

        if ! curl -sLf --fail -o ./response.txt "$URL"; then
            log "ERROR" "Unable to fetch latest version from Kubernetes releases!"
            exit 1
        fi

        VERSION=$(cat ./response.txt | sed 's/v//')
        log "INFO" "Latest version found: v$VERSION"
    else
        VERSION=$(echo "$VERSION" | sed 's/v//')
        log "INFO" "Using specified version: v$VERSION"
    fi

    export VERSION
}

detect_arch() {
    log "INFO" "Detecting system architecture..."
    case "$(uname -m)" in
        x86_64 | amd64) ARCH="amd64" ;;
        aarch64 | arm64) ARCH="arm64" ;;
        *) log "ERROR" "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
    log "INFO" "Architecture detected: $ARCH"
    export ARCH
}

download_binary() {
    if [ -z "$VERSION" ]; then
        log "ERROR" "Missing version information!"
        exit 1
    fi

    URL="https://dl.k8s.io/release/v${VERSION}/bin/linux/${ARCH}/kubectl"
    log "INFO" "Downloading Kubectl from $URL"

    if ! curl -sLf --fail -o ./kubectl "$URL"; then
        log "ERROR" "Failed to download Kubectl!"
        exit 1
    fi

    log "INFO" "Download complete!"
}

install_binary() {
    log "INFO" "Installing Kubectl..."
    install -m 0755 ./kubectl /usr/local/bin/kubectl
    log "INFO" "Kubectl installed successfully to /usr/local/bin/kubectl"
}

log "INFO" "Activating feature 'kubectl'"

get_version
detect_arch
download_binary
install_binary

log "INFO" "Installation complete!"
