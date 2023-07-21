#!/bin/sh
set -e

echo "Activating feature 'kubectl'"
curl -Lo ./kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
chown root:root ./kubectl
mv ./kubectl /usr/local/bin/kubectl
