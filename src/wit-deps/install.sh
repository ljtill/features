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

check_deps curl ca-certificates jq

get_version() {
    VERSION="${VERSION:-latest}"

    if [ "$VERSION" = "latest" ]; then
        log "INFO" "Fetching latest WIT Deps version from GitHub..."
        URL="https://api.github.com/repos/bytecodealliance/wit-deps/releases/latest"

        if ! curl -sLf --fail -o ./response.json "$URL"; then
            log "ERROR" "Unable to fetch latest version from GitHub API!"
            exit 1
        fi

        VERSION=$(jq -r ".tag_name" < ./response.json | sed 's/v//')
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
        x86_64 | amd64) ARCH="x86_64" ;;
        aarch64 | arm64) ARCH="aarch64" ;;
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

    URL="https://github.com/bytecodealliance/wit-deps/releases/download/v${VERSION}/wit-deps-${ARCH}-unknown-linux-musl"
    log "INFO" "Downloading WIT Deps from $URL"

    if ! curl -sLf --fail -o ./wit-deps "$URL"; then
        log "ERROR" "Failed to download WIT Deps!"
        exit 1
    fi

    log "INFO" "Download complete!"
}

install_binary() {
    log "INFO" "Installing WIT Deps..."
    install -m 0755 ./wit-deps /usr/local/bin/wit-deps
    log "INFO" "WIT Deps installed successfully to /usr/local/bin/wit-deps"
}

log "INFO" "Activating feature 'wit-deps'"

get_version
detect_arch
download_binary
install_binary

log "INFO" "Installation complete!"
