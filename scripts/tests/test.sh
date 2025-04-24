#!/bin/bash
set -e
source $IAC_ROOT/.venv/bin/activate

source $IAC_ROOT/scripts/tests/test_init.sh $1

terraform fmt

# check & fix
python3 $IAC_ROOT/scripts/tests/check.py validate $identifier
python3 $IAC_ROOT/scripts/tests/check.py tflint $identifier
python3 $IAC_ROOT/scripts/tests/check.py checkov $identifier
python3 $IAC_ROOT/scripts/tests/check.py test_plan $identifier

deactivate
