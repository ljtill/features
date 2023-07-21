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
    version=$(curl -sL https://api.github.com/repos/fluxcd/flux2/releases/latest | jq -r ".tag_name" | sed 's/v//')
    curl -Lo ./flux_"$version"_linux_amd64.tar.gz https://github.com/fluxcd/flux2/releases/download/v"$version"/flux_"$version"_linux_amd64.tar.gz
    tar -zxof ./flux_"$version"_linux_amd64.tar.gz
    rm -f ./flux_"$version"_linux_amd64.tar.gz
    chmod +x ./flux
    chown root:root ./flux
    mv ./flux /usr/local/bin/flux
}

echo "Activating feature 'flux'"

install
