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
        export VERSION=$(curl -sL https://api.github.com/repos/projectcalico/calico/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./calicoctl https://github.com/projectcalico/calico/releases/download/v"${VERSION}"/calicoctl-linux-amd64
}

install() {
    chmod +x ./calicoctl
    chown root:root ./calicoctl
    mv ./calicoctl /usr/local/bin/calicoctl
}

echo "Activating feature 'calicoctl'"

version
download
install
