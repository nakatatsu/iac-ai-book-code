#!/bin/bash
set -e
source $IAC_ROOT/.venv/bin/activate

python3 $IAC_ROOT/scripts/requirements/generate.py "$1"

deactivate
