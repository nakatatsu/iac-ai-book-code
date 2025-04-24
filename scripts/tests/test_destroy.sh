#!/bin/bash

set -e

source $IAC_ROOT/scripts/tests/cd_module_dir.sh $1

module_path=$(pwd)
if [ -d $module_path/.terraform ]; then
  terraform destroy -no-color -parallelism=30 -compact-warnings -var-file="${module_path}/tests/terraform.tfvars.json"
fi

rm -f $module_path/*.tfstate.backup
rm -f $module_path/*.tfstate
rm -f $module_path/.terraform.lock.hcl
rm -rf $module_path/.terraform
rm -f $module_path/providers.tf
