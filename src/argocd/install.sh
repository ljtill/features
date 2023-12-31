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
        export VERSION=$(curl -sL https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./argocd https://github.com/argoproj/argo-cd/releases/download/v"${VERSION}"/argocd-linux-amd64
}

install() {
    chmod +x ./argocd
    chown root:root ./argocd
    mv ./argocd /usr/local/bin/argocd
}

echo "Activating feature 'argocd'"

version
download
install
