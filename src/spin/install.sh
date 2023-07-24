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

check curl ca-certificates git

install() {
    curl https://developer.fermyon.com/downloads/install.sh | bash
    chmod +x ./spin
    chown root:root ./spin
    mv ./spin /usr/local/bin/spin
}

echo "Activating feature 'spin'"

install
