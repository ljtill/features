#!/bin/sh
set -e

cd "$(mktemp -d)"

check() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt update..."
            apt update -y
        fi
        apt -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

check curl ca-certificates jq

version() {
    if [ "${VERSION}" = "latest" ]; then
        URL="https://api.github.com/repos/kubernetes-sigs/cluster-api/releases/latest"
        if ! curl -sLf -o ./response.json "$URL"; then
            echo "ERROR: Unable to fetch latest version"
            exit 1
        fi
        export VERSION=$(cat ./response.json | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    URL="https://github.com/kubernetes-sigs/cluster-api/releases/download/v"${VERSION}"/clusterctl-linux-amd64"
    if ! curl -sLf -o ./clusterctl "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    chmod +x ./clusterctl
    chown root:root ./clusterctl
    mv ./clusterctl /usr/local/bin/clusterctl
}

echo "Activating feature 'clusterctl'"

version
download
install
