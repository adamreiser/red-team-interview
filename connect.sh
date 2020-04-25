#!/bin/bash

set -eu

# script for ssh access using local terraform-managed ssh config
# usage: ./connect.sh <uuid> <host identifier>

TF_VAR_session=$(echo -n "${1}" | cut -d. -f1 | tr -d "\\n")

ssh -F ".ssh/${TF_VAR_session}_config" "${2}"
