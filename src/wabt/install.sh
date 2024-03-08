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
        export VERSION=$(curl -sL https://api.github.com/repos/WebAssembly/wabt/releases/latest | jq -r ".tag_name")
    else
        export VERSION=$(echo ${VERSION})
    fi
}

download() {
    curl -Lo ./wabt-"${VERSION}"-ubuntu.tar.gz https://github.com/WebAssembly/wabt/releases/download/"${VERSION}"/wabt-"${VERSION}"-ubuntu.tar.gz
}

install() {
    tar -zxof ./wabt-"${VERSION}"-ubuntu.tar.gz
    chown -R root:root ./wabt-"${VERSION}"
    mv ./wabt-"${VERSION}" /usr/local/lib/wabt
}

link() {
    ln -s ../lib/wabt/bin/wasm2c /usr/local/bin/wasm2c
    ln -s ../lib/wabt/bin/wasm2wat /usr/local/bin/wasm2wat
    ln -s ../lib/wabt/bin/wasm-decompile /usr/local/bin/wasm-decompile
    ln -s ../lib/wabt/bin/wasm-interp /usr/local/bin/wasm-interp
    ln -s ../lib/wabt/bin/wasm-objdump /usr/local/bin/wasm-objdump
    ln -s ../lib/wabt/bin/wasm-stats /usr/local/bin/wasm-stats
    ln -s ../lib/wabt/bin/wasm-strip /usr/local/bin/wasm-strip
    ln -s ../lib/wabt/bin/wasm-validate /usr/local/bin/wasm-validate
    ln -s ../lib/wabt/bin/wast2json /usr/local/bin/wast2json
    ln -s ../lib/wabt/bin/wat2wasm /usr/local/bin/wat2wasm
    ln -s ../lib/wabt/bin/wat-desugar /usr/local/bin/wat-desugar
}

echo "Activating feature 'wabt'"

version
download
install
link
