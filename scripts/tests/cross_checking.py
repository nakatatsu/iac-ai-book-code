import os
import sys
import shutil
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))
from shared import utils


def main() -> None:
    if (identifier := utils.get_cli_arg(1)) is None:
        print("Please provide a module name as a command-line argument.")
        sys.exit(1)

    type = utils.get_cli_arg(2, "general")
    template_file = f"cross_checking.j2"

    path_prefix = utils.get_path_prefix(identifier, type)

    main_code_filepath = f"{path_prefix}main.tf"

    print(f"cross checking ...")
    prompt = utils.render(
        f"{utils.SCRIPTS_DIR}/tests/cross_checking.j2",
        {
            "specification": utils.load(f"{path_prefix}specification.md"),
            "project_information": utils.load(f"{utils.DOCUMENTS_DIR}/project_information.md"),
            "coding_guideline": utils.load(f"{utils.DOCUMENTS_DIR}/coding_guidelines.md"),
            "code": utils.load(main_code_filepath),
            "variable_code": utils.load(f"{path_prefix}variables.tf"),
            "output_code": utils.load(f"{path_prefix}outputs.tf"),
        },
    )

    response = utils.ask(prompt)

    if response == "Nothing":
        print("cross checking is successful.")
        sys.exit(0)

    suggestion_file_path = utils.get_suggestion_file_name(main_code_filepath)
    utils.save(suggestion_file_path, response)


if __name__ == "__main__":
    main()
