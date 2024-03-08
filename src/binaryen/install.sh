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
        export VERSION=$(curl -sL https://api.github.com/repos/WebAssembly/binaryen/releases/latest | jq -r ".tag_name")
    else
        export VERSION=$(echo ${VERSION})
    fi
}

download() {
    curl -Lo ./binaryen-"${VERSION}"-x86_64-linux.tar.gz https://github.com/WebAssembly/binaryen/releases/download/"${VERSION}"/binaryen-"${VERSION}"-x86_64-linux.tar.gz
}

install() {
    tar -zxof ./binaryen-"${VERSION}"-x86_64-linux.tar.gz
    chown -R root:root ./binaryen-"${VERSION}"
    mv ./binaryen-"${VERSION}" /usr/local/lib/binaryen
}

link() {
    ln -s ../lib/binaryen/bin/wasm2js /usr/local/bin/wasm2js
    ln -s ../lib/binaryen/bin/wasm-as /usr/local/bin/wasm-as
    ln -s ../lib/binaryen/bin/wasm-ctor-eval /usr/local/bin/wasm-ctor-eval
    ln -s ../lib/binaryen/bin/wasm-dis /usr/local/bin/wasm-dis
    ln -s ../lib/binaryen/bin/wasm-emscripten-finalize /usr/local/bin/wasm-emscripten-finalize
    ln -s ../lib/binaryen/bin/wasm-fuzz-lattices /usr/local/bin/wasm-fuzz-lattices
    ln -s ../lib/binaryen/bin/wasm-fuzz-types /usr/local/bin/wasm-fuzz-types
    ln -s ../lib/binaryen/bin/wasm-merge /usr/local/bin/wasm-merge
    ln -s ../lib/binaryen/bin/wasm-metadce /usr/local/bin/wasm-metadce
    ln -s ../lib/binaryen/bin/wasm-opt /usr/local/bin/wasm-opt
    ln -s ../lib/binaryen/bin/wasm-reduce /usr/local/bin/wasm-reduce
    ln -s ../lib/binaryen/bin/wasm-shell /usr/local/bin/wasm-shell
    ln -s ../lib/binaryen/bin/wasm-split /usr/local/bin/wasm-split
}

echo "Activating feature 'binaryen'"

version
download
install
link
