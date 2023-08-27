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

check curl ca-certificates

install() {
    curl -Lo ./kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    chown root:root ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
}

options() {
    if [ "${KUBELOGIN}" = "true" ]; then
        curl -Lo ./kubelogin-linux-amd64.zip https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip
        unzip ./kubelogin-linux-amd64.zip
        rm ./kubelogin-linux-amd64.zip
        chmod +x ./bin/linux_amd64/kubelogin
        chown root:root ./bin/linux_amd64/kubelogin
        mv ./bin/linux_amd64/kubelogin /usr/local/bin/kubelogin
    fi
    if [ "${NODESHELL}" = "true" ]; then
        curl -Lo ./kubectl-node_shell https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
        chmod +x ./kubectl-node_shell
        chown root:root ./kubectl-node_shell
        mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell
    fi
}

echo "Activating feature 'kubectl'"

install
options
