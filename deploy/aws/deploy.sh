#!/bin/sh

# exit immediately if a command exits with a non-zero status
set -e

log() {
    echo -e "\033[1;${1}m${2}\033[m"
}

deploy() {
    local VERSION="$1"
    log 36 "Version: $VERSION"
    # gomplate replace setting
    VERSION=$VERSION gomplate --input-dir=template \
        --output-dir=dist
    # change to dist folder
    cd dist
    # terraform init
    terraform init
    # terraform apply -auto-approve -input=false
    terraform apply -auto-approve -input=false
}

deploy "$@"

exit 0
