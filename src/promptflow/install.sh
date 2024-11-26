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

check python3 python3-venv

install() {
    python3 -m venv /opt/python3/venvs/promptflow
    /opt/python3/venvs/promptflow/bin/pip3 install promptflow promptflow-tools promptflow-azure

    ln -s /opt/python3/venvs/promptflow/bin/pf /usr/local/bin/pf
    ln -s /opt/python3/venvs/promptflow/bin/pfazure /usr/local/bin/pfazure
}

echo "Activating feature 'promptflow'"

install
