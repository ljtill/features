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
        export VERSION=$(curl -sL https://api.github.com/repos/go-task/task/releases/latest | jq -r ".tag_name" | cut -d'-' -f 4 | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./task_linux_amd64.tar.gz https://github.com/go-task/task/releases/download/v"${VERSION}"/task_linux_amd64.tar.gz
}

install() {
    tar -zxof ./task_linux_amd64.tar.gz
    chmod +x ./task
    chown root:root ./task
    mv ./task /usr/local/bin/task
}

echo "Activating feature 'task'"

version
download
install
