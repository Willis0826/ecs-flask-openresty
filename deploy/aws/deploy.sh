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
    log 36 "Start to replace templates..."
    VERSION=$VERSION gomplate --input-dir=template \
        --output-dir=dist -V
    # change to dist folder
    log 36 "Start to using terraform with replaced templates..."
    cd dist
    # terraform init
    terraform init
    # terraform plan
    terraform plan
    # terraform apply -auto-approve -input=false
    terraform apply -auto-approve -input=false
}

deploy "$@"

exit 0
