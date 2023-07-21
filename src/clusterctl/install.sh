#!/bin/sh
set -e

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

install() {
    version=$(curl -sL https://api.github.com/repos/kubernetes-sigs/cluster-api/releases/latest | jq -r ".tag_name" | sed 's/v//')
    curl -Lo ./clusterctl https://github.com/kubernetes-sigs/cluster-api/releases/download/v"$version"/clusterctl-linux-amd64
    chmod +x ./clusterctl
    chown root:root ./clusterctl
    mv ./clusterctl /usr/local/bin/clusterctl
}

echo "Activating feature 'clusterctl'"

install
