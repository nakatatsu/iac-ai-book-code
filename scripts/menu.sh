#!/bin/bash

MODULE_DIR="$IAC_ROOT/src/terraform/modules"

dirs=($(find ${MODULE_DIR} -mindepth 1 -maxdepth 1 -type d -printf "%f\n"))

echo "実行したいコマンドを選択してください:"
PS3="Select command: "
select command in "prepare" "requirements" "specification" "code" "cross_checking" "test" "clean_up"; do
    if [[ -n "$command" ]]; then
        break
    fi
done


if [[ "$command" == "prepare" ]]; then
    read -p "モジュール名を入力してください: " identifier
else
    PS3="Select module: "
    select identifier in "${dirs[@]}"; do
        if [[ -n "$identifier" ]]; then
            break
        fi
    done
fi

# 特殊なコマンドの場合、typeを入力させる
if [[ "$command" == "specification" || "$command" == "code" || "$command" == "cross_checking" ]]; then
    read -p "typeを入力してください (例: general,security_group, iam): " type
fi

cd $IAC_ROOT

if [[ -z "$type" ]]; then
    echo "make $command identifier=$identifier"
    make $command identifier=$identifier
else
    echo "make $command identifier=$identifier type=$type"
    make $command identifier=$identifier type=$type
fi
