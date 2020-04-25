#!/bin/bash

set -eu

source .env

export TF_VAR_session='terraform'

terraform init

if [ "$(uname)" == 'Darwin' ]; then
    TF_VAR_session=$(uuidgen | tr '[:upper:]' '[:lower:]')
else
    TF_VAR_session=$(cat /proc/sys/kernel/random/uuid)
fi

echo "Creating interview ${TF_VAR_session}..."
trap './destroy.sh ${TF_VAR_session}' ERR INT

mkdir -m 0700 -p .ssh

# specify pem format for windows password decryption
yes | ssh-keygen -q -m pem -t rsa -N '' -C '' -f ".ssh/${TF_VAR_session}.pem"

terraform plan -out "${TF_VAR_session}.tfplan"

# TF_VAR variables aren't getting set automatically
terraform apply "-state=${TF_VAR_session}.tfstate" "${TF_VAR_session}.tfplan"
