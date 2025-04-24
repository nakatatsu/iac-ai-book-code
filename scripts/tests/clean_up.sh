#!/bin/bash
set -e

source $IAC_ROOT/scripts/tests/cd_module_dir.sh $1

module_path=$(pwd)
echo "clean up module_path: $module_path"

rm -f $module_path/*.tf.*.back
rm -f $module_path/*.tf.*.suggestion
rm -f $module_path/specification.*.suggestion
