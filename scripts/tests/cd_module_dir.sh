#!/bin/bash

set -e

if [ -z "$IAC_ROOT" ]; then
  echo "Error: IAC_ROOT is not set. Please refer to documents/usage.md to set the environment variable."
  exit 1
fi

MODULE_DIR="$IAC_ROOT/src/terraform/modules"

if [ -n "$1" ]; then
  identifier="$1"
else
  dirs=($(find ${MODULE_DIR} -mindepth 1 -maxdepth 1 -type d -printf "%f\n"))
  PS3="Select module: "
  select identifier in "${dirs[@]}"; do
    if [[ -n "$identifier" ]]; then
      break
    fi
  done
fi

module_path="${MODULE_DIR}/$identifier"

if [ ! -d "$module_path" ]; then
  echo "Error: $module_path is not found. Please specify a valid module name."
  exit 1
fi

cd $module_path
