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
        URL="https://api.github.com/repos/mongodb/mongodb-atlas-cli/releases/latest"
        if ! curl -sLf -o ./response.json "$URL"; then
            echo "ERROR: Unable to fetch latest version"
            exit 1
        fi
        export VERSION=$(cat ./response.json | jq -r '.tag_name | sub("atlascli/v"; "")')
    else
        export VERSION=$(echo ${VERSION} | sed 's/v//')
    fi
}

download() {
    ARCH="$(dpkg --print-architecture)"

    case ${ARCH} in
    amd64)
        URL="https://github.com/mongodb/mongodb-atlas-cli/releases/download/atlascli%2Fv"${VERSION}"/mongodb-atlas-cli_"${VERSION}"_linux_x86_64.deb"
        ;;
    arm64)
        URL="https://github.com/mongodb/mongodb-atlas-cli/releases/download/atlascli%2Fv"${VERSION}"/mongodb-atlas-cli_"${VERSION}"_linux_arm64.deb"
        ;;
    *) echo "(!) Architecture ${architecture} not supported."
        exit 1
        ;;
    esac

    if ! curl -sLf -o ./mongodb-atlas-cli.deb "$URL"; then
        echo "ERROR: Unable to download file"
        exit 1
    fi
}

install() {
    chown root:root ./mongodb-atlas-cli.deb
    apt install ./mongodb-atlas-cli.deb
}

echo "Activating feature 'atlas'"

version
download
install
