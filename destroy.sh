#!/bin/bash

# Destroys the given terraform instance and removes associated local files on success

set -eu

if [ $# != 1 ]; then
    echo "${0}: Missing argument: <session UUID>"
    exit 1
elif [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
    echo "Usage: ${0} <session UUID>"
    exit 0
fi

TF_VAR_session=$(echo -n "${1}" | cut -d. -f1 | tr -d "\\n")

echo "Destroying ${TF_VAR_session}..."
source .env

trap 'echo "Destruction failed!"' ERR INT
terraform destroy "-state=${TF_VAR_session}.tfstate" -var "session=${TF_VAR_session}" -backup=- -auto-approve

rm -f ".ssh/${TF_VAR_session}_known_hosts" ".ssh/${TF_VAR_session}.pem" ".ssh/${TF_VAR_session}.pem.pub"

rm -f "${TF_VAR_session}.tfstate" "${TF_VAR_session}.tfplan"

echo "Destruction complete."
