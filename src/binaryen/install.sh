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
        URL="https://api.github.com/repos/WebAssembly/binaryen/releases/latest"
        if ! curl -sLf -o ./response.json "$URL"; then
            echo "ERROR: Unable to fetch latest version"
            exit 1
        fi
        export VERSION=$(cat ./response.json | jq -r ".tag_name" | sed 's/version_//')
    else
        export VERSION=$(echo ${VERSION} | sed 's/version_//')
    fi
}

download() {
    URL="https://github.com/WebAssembly/binaryen/releases/download/version_"${VERSION}"/binaryen-version_"${VERSION}"-x86_64-linux.tar.gz"
    if ! curl -sLf -o ./binaryen-version_"${VERSION}"-x86_64-linux.tar.gz "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    tar -zxof ./binaryen-version_"${VERSION}"-x86_64-linux.tar.gz
    chown -R root:root ./binaryen-version_"${VERSION}"
    mv ./binaryen-version_"${VERSION}" /opt/binaryen
}

link() {
    ln -s /opt/binaryen/bin/wasm2js /usr/local/bin/wasm2js
    ln -s /opt/binaryen/bin/wasm-as /usr/local/bin/wasm-as
    ln -s /opt/binaryen/bin/wasm-ctor-eval /usr/local/bin/wasm-ctor-eval
    ln -s /opt/binaryen/bin/wasm-dis /usr/local/bin/wasm-dis
    ln -s /opt/binaryen/bin/wasm-emscripten-finalize /usr/local/bin/wasm-emscripten-finalize
    ln -s /opt/binaryen/bin/wasm-fuzz-lattices /usr/local/bin/wasm-fuzz-lattices
    ln -s /opt/binaryen/bin/wasm-fuzz-types /usr/local/bin/wasm-fuzz-types
    ln -s /opt/binaryen/bin/wasm-merge /usr/local/bin/wasm-merge
    ln -s /opt/binaryen/bin/wasm-metadce /usr/local/bin/wasm-metadce
    ln -s /opt/binaryen/bin/wasm-opt /usr/local/bin/wasm-opt
    ln -s /opt/binaryen/bin/wasm-reduce /usr/local/bin/wasm-reduce
    ln -s /opt/binaryen/bin/wasm-shell /usr/local/bin/wasm-shell
    ln -s /opt/binaryen/bin/wasm-split /usr/local/bin/wasm-split
}

echo "Activating feature 'binaryen'"

version
download
install
link
