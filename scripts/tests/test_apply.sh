#!/bin/bash
set -e

source $IAC_ROOT/scripts/tests/test_init.sh $1
terraform apply -input=false -no-color -parallelism=30 -compact-warnings -var-file="${module_path}/tests/terraform.tfvars.json"
exit $?
