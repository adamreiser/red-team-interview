#!/bin/bash

set -e

# To validate the cloud init yml files, run this on a host with cloud-init
# cloud-init devel schema --config-file provision.yml

terraform validate
shellcheck ./*.sh .env

echo "All tests passed."
