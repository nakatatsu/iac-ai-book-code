#!/bin/bash

set -e

if [ -z "$IAC_ROOT" ]; then
  echo "Error: IAC_ROOT is not set. Please refer to documents/usage.md to set the environment variable."
  exit 1
fi

identifier="$1"

if [ -z "$identifier" ]; then
  read -p "Please enter the identifier: " identifier
fi

output="$IAC_ROOT/src/terraform/modules/$identifier"

mkdir -p $output/tests
touch $output/readme.md
touch $output/main.tf
touch $output/outputs.tf
touch $output/variables.tf
touch $output/tests/terraform.tfvars.json

echo "Skeleton prepared at $output."

