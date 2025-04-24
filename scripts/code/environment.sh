#!/bin/bash
set -e
source $IAC_ROOT/.venv/bin/activate

python3 $IAC_ROOT/scripts/code/environment.py "$1" "$2"

deactivate
