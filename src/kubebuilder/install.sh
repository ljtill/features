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
        export VERSION=$(curl -sLf https://api.github.com/repos/kubernetes-sigs/kubebuilder/releases/latest | jq -r ".tag_name" | sed 's/v//')
        if [ $? -ne 0 ]; then
            echo "Version check failed"
            exit 1
        fi
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -sLf -o ./kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/download/v"${VERSION}"/kubebuilder_linux_amd64
    if [ $? -ne 0 ]; then
        echo "File download failed"
        exit 1
    fi
}

install() {
    chmod +x ./kubebuilder
    chown root:root ./kubebuilder
    mv ./kubebuilder /usr/local/bin/kubebuilder
}

echo "Activating feature 'kubebuilder'"

version
download
install
