import sys
import re
import os
import subprocess
import shutil

from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))
from shared import utils


# チェックを実行する
def check(check_type: str, identifier: str) -> subprocess.CompletedProcess:
    result = subprocess.run(
        ["bash", f"{utils.SCRIPTS_DIR}/tests/{check_type}.sh", identifier],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return result


def extract_unique_tf_filenames(text: str) -> list[str]:
    pattern = r"\b[a-zA-Z_]+\.tf\b"
    matches = re.findall(pattern, text)

    unique_filenames = list(set(matches))
    return unique_filenames


def fix_terraform_code_with_ai(error_message: str, terraform_file: str, module_path: str) -> tuple[str, str]:
    terraform_file_path = os.path.join(module_path, terraform_file)
    terraform_code = utils.load(terraform_file_path)
    prompt = utils.render(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "fix.j2"),
        {
            "error_message": error_message,
            "terraform_code": terraform_code,
        },
    )

    response = utils.ask(prompt)

    backup_file_path = utils.get_backup_file_name(terraform_file_path)
    shutil.copy2(terraform_file_path, backup_file_path)

    suggestion_file_path = utils.get_suggestion_file_name(terraform_file_path)
    utils.save(suggestion_file_path, response)

    utils.save(terraform_file_path, response)
    return terraform_file_path, backup_file_path


def pick_error_message_terraform(log: str) -> str:
    lines = log.splitlines()
    for i, line in enumerate(lines):
        if line.startswith("Error:"):
            return "\n".join(lines[i:])
    return ""


def main(check_type: str, identifier: str) -> None:
    module_path = f"{utils.MODULES_DIR}/{identifier}"

    print(f"check {identifier} with {check_type} ...")

    # チェックを実行する
    result = check(check_type, identifier)

    # すべて解決していたら終了する
    exit_code = result.returncode
    if exit_code == 0:
        print(result.stdout + result.stderr)
        print("No problems. Exiting.")
        sys.exit(0)

    if check_type == "test_apply" or check_type == "test_plan":
        error_message = pick_error_message_terraform(result.stderr)
    else:
        error_message = result.stdout + result.stderr

    print(f"found issues:\n{error_message}")

    filenames = extract_unique_tf_filenames(error_message)
    rollbacks = []
    for terraform_file in filenames:
        file, backup_file = fix_terraform_code_with_ai(error_message, terraform_file, module_path)
        print(f"fix {file}")
        rollbacks.append([terraform_file, backup_file])

    # チェックを実行する
    result = check(check_type, identifier)

    # 解決していなかったらロールバックする
    exit_code = result.returncode
    if exit_code != 0:
        print(result.stdout + result.stderr)
        print("fix is failed...")
        for rollback in rollbacks:
            shutil.copy2(rollback[1], rollback[0])
            print(f"rollback {rollback[0]}")

        sys.exit(1)

    print("fix is successful.")
    sys.exit(0)


if __name__ == "__main__":

    if len(sys.argv) < 3:
        print("Please provide the check function name and module name as an argument.")
        sys.exit(1)

    check_type = sys.argv[1]
    identifier = sys.argv[2]
    main(check_type, identifier)
    sys.exit(0)
