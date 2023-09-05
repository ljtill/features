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
        export VERSION=$(curl -sL https://api.github.com/repos/kubernetes/kubernetes/releases/latest | jq -r ".tag_name" | sed 's/v//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    curl -Lo ./kubectl https://dl.k8s.io/release/"${VERSION}"/bin/linux/amd64/kubectl
}

download() {
    if [ "${VERSION}" = "latest" ]; then
        curl -Lo ./kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
    else
        curl -Lo ./kubectl https://dl.k8s.io/release/v$VERSION/bin/linux/amd64/kubectl
    fi
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

<<<<<<< Updated upstream
=======
version
>>>>>>> Stashed changes
download
install
options
