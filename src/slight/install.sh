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
    version=$(curl -sL https://api.github.com/repos/deislabs/spiderlightning/releases/latest | jq -r ".tag_name" | sed 's/v//')
    curl -Lo ./slight-linux-x86_64.tar.gz https://github.com/deislabs/spiderlightning/releases/download/v"$version"/slight-linux-x86_64.tar.gz
    tar -zxof ./slight-linux-x86_64.tar.gz
    rm -f ./slight-linux-x86_64.tar.gz
    chmod +x ./slight
    chown root:root ./slight
    mv ./spin /usr/local/bin/slight
}

echo "Activating feature 'slight'"

install
