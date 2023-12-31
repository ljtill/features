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

check curl ca-certificates jq git

version() {
    if [ "${VERSION}" = "latest" ]; then
        export VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./kubectl https://dl.k8s.io/release/v"${VERSION}"/bin/linux/amd64/kubectl
}

install() {
    chmod +x ./kubectl
    chown root:root ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
}

options() {
    if [ "${KREW}" = "true" ]; then
        curl -Lo ./krew-linux_amd64.tar.gz https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz
        tar -zxof ./krew-linux_amd64.tar.gz
        ./krew-linux_amd64 install krew
        chmod -R +rx /usr/local/krew/store/krew
    fi
    if [ "${KUBECTX}" = "true" ]; then
        curl -Lo ./kubectx https://github.com/ahmetb/kubectx/releases/latest/download/kubectx
        curl -Lo ./kubens https://github.com/ahmetb/kubectx/releases/latest/download/kubens
        chmod +x ./kubectx
        chmod +x ./kubens
        chown root:root ./kubectx
        chown root:root ./kubens
        mv ./kubectx /usr/local/bin/kubectx
        mv ./kubens /usr/local/bin/kubens
    fi
    if [ "${KUBELOGIN}" = "true" ]; then
        curl -Lo ./kubelogin-linux-amd64.zip https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip
        unzip ./kubelogin-linux-amd64.zip
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

version
download
install
options
