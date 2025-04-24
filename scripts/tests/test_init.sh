#!/bin/bash
# For TEST ONLY. Never use this script in production.

set -e

module_name=$1

source $IAC_ROOT/scripts/tests/cd_module_dir.sh $module_name

if [ -n "$2" ]; then
  output="$2"
else
  output="/dev/null"
fi


cp $IAC_ROOT/src/terraform/tests/providers.tf $IAC_ROOT/src/terraform/modules/$module_name/providers.tf
terraform init > $output
