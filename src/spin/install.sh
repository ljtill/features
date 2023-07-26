#!/bin/sh
set -e

cd /tmp

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
    version=$(curl -sL https://api.github.com/repos/fermyon/spin/releases/latest | jq -r ".tag_name" | sed 's/v//')
    curl -Lo ./spin-linux-amd64.tar.gz https://github.com/fermyon/spin/releases/download/v"$version"/spin-v"$version"-linux-amd64.tar.gz
    tar -zxof ./spin-linux-amd64.tar.gz
    rm -f ./spin-linux-amd64.tar.gz
    chmod +x ./spin
    chown root:root ./spin
    mv ./spin /usr/local/bin/spin
}

echo "Activating feature 'spin'"

install
