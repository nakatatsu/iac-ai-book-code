import os
import sys

from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))
from shared import utils


def main() -> None:
    if (environment := utils.get_cli_arg(1)) is None:
        print("Please provide a environment name as a command-line argument.")
        sys.exit(1)

    if (tmp_modules := utils.get_cli_arg(2)) is None:
        print("Please provide a modules name as a command-line argument. e.g., 'networking,iam,security_group,api'")
        sys.exit(1)

    modules = tmp_modules.split(",")
    module_codes = {}
    for module in modules:
        module_codes[module] = {
            "variables": utils.load(f"{utils.MODULES_DIR}/{module}/variables.tf"),
            "outputs": utils.load(f"{utils.MODULES_DIR}/{module}/outputs.tf"),
        }

    path_prefix = f"{utils.ENVIRONMENT_DIR}/{environment}/"

    prompt = utils.render(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "environment.j2"),
        {
            "environment": environment,
            "project_information": utils.load(f"{utils.DOCUMENTS_DIR}/project_information.md"),
            "coding_guideline": utils.load(f"{utils.DOCUMENTS_DIR}/coding_guidelines.md"),
            "module_codes": module_codes,
        },
    )

    response = utils.ask(prompt)
    main_contents, variables_contents, _ = utils.extract_tf_contents(response)

    utils.save(utils.get_suggestion_file_name(f"{path_prefix}main.tf"), main_contents)
    utils.save(utils.get_suggestion_file_name(f"{path_prefix}variables.tf"), variables_contents)


if __name__ == "__main__":
    main()
