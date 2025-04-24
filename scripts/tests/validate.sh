#!/bin/bash
set -e

source $IAC_ROOT/scripts/tests/cd_module_dir.sh $1
echo "Testing with Terraform validate..."
terraform validate
exit $?
