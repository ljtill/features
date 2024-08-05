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
        RESPONSE=$(curl -sL -w "%{http_code}" https://dl.k8s.io/release/stable.txt | sed 's/v//')
        HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
        
        if [ "$HTTP_STATUS" -eq 200 ]; then
            export VERSION=$(echo "$RESPONSE" | sed '$d' | jq -r ".tag_name")
        else
            echo "Failed to fetch the latest version."
            exit 1
        fi
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    RESPONSE=$(curl -sL -w "%{http_code}" -o ./kubectl https://dl.k8s.io/release/v"${VERSION}"/bin/linux/amd64/kubectl)
    HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

    if [ "$HTTP_STATUS" -ne 200 ]; then
        echo "Failed to download file"
        exit 1
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
        if [ $? -ne 0 ]; then
            echo "File download failed"
            exit 1
        fi

        tar -zxof ./krew-linux_amd64.tar.gz
        ./krew-linux_amd64 install krew
        chmod -R +rx /usr/local/krew/store/krew
    fi

    if [ "${KUBECTX}" = "true" ]; then
        curl -Lo ./kubectx https://github.com/ahmetb/kubectx/releases/latest/download/kubectx
        if [ $? -ne 0 ]; then
            echo "File download failed"
            exit 1
        fi

        curl -Lo ./kubens https://github.com/ahmetb/kubectx/releases/latest/download/kubens
        if [ $? -ne 0 ]; then
            echo "File download failed"
            exit 1
        fi

        chmod +x ./kubectx
        chmod +x ./kubens
        chown root:root ./kubectx
        chown root:root ./kubens
        mv ./kubectx /usr/local/bin/kubectx
        mv ./kubens /usr/local/bin/kubens
    fi
    if [ "${KUBELOGIN}" = "true" ]; then
        curl -Lo ./kubelogin-linux-amd64.zip https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip
        if [ $? -ne 0 ]; then
            echo "File download failed"
            exit 1
        fi
        
        unzip ./kubelogin-linux-amd64.zip
        chmod +x ./bin/linux_amd64/kubelogin
        chown root:root ./bin/linux_amd64/kubelogin
        mv ./bin/linux_amd64/kubelogin /usr/local/bin/kubelogin
    fi
    if [ "${NODESHELL}" = "true" ]; then
        curl -Lo ./kubectl-node_shell https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
        if [ $? -ne 0 ]; then
            echo "File download failed"
            exit 1
        fi

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
