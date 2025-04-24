#!/bin/bash
set -e

source $IAC_ROOT/scripts/tests/cd_module_dir.sh $1

echo "Testing with TFLint..."
tflint --recursive --config "$IAC_ROOT/src/terraform/tests/.tflint.hcl"
exit $?
