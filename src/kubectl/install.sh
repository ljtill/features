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

check curl

install() {
    echo "Activating feature 'kubectl'"
    curl -Lo ./kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    chown root:root ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
}

install
