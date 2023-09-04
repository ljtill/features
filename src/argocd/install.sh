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

check curl ca-certificates

download() {
    if [ "${VERSION}" = "latest" ]; then
        curl -Lo ./argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    else
        curl -Lo ./argocd https://github.com/argoproj/argo-cd/releases/v$VERSION/download/argocd-linux-amd64
    fi
}

install() {
    chmod +x ./argocd
    chown root:root ./argocd
    mv ./argocd /usr/local/bin/argocd
}

echo "Activating feature 'argocd'"

download
install
