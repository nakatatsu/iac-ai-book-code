#!/bin/bash
set -e

source $IAC_ROOT/scripts/tests/cd_module_dir.sh $1

# openaiとコンフリクトしたため、いったんcheckovを隔離している
source $IAC_ROOT/.venv_checkov/bin/activate

# use `-o json` to output json
echo "Testing with Checkov..."
checkov -d . --config-file "$IAC_ROOT/src/terraform/tests/.checkov.yml"

deactivate

exit $?
