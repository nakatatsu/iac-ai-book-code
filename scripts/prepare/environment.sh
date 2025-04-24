#!/bin/bash

set -e

if [ -z "$IAC_ROOT" ]; then
  echo "Error: IAC_ROOT is not set. Please refer to documents/usage.md to set the environment variable."
  exit 1
fi

environment="$1"

if [ -z "$environment" ]; then
  read -p "Please enter the environment name: " environment
fi

output="$IAC_ROOT/src/terraform/$environment"

mkdir -p $output
touch $output/readme.md
touch $output/main.tf
touch $output/variables.tf
touch $output/terraform.tfvars.json
echo "include ../../../Makefile.env" > $output/Makefile

echo "Skeleton prepared at $output."

