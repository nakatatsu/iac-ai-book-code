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
    template_file = f"{type}.j2"

    path_prefix = utils.get_path_prefix(identifier, type)

    specification_path = f"{path_prefix}specification.md"

    prompt = utils.render(
        f"{utils.SCRIPTS_DIR}/reverse_engineering/general.j2",
        {
            "specification": utils.load(specification_path),
            "project_information": utils.load(f"{utils.DOCUMENTS_DIR}/project_information.md"),
            "coding_guideline": utils.load(f"{utils.DOCUMENTS_DIR}/coding_guidelines.md"),
            "main_code": utils.load(f"{path_prefix}main.tf"),
            "variable_code": utils.load(f"{path_prefix}variables.tf"),
            "output_code": utils.load(f"{path_prefix}outputs.tf"),
        },
    )

    response = utils.ask(prompt)
    suggestion_file_path = utils.get_suggestion_file_name(specification_path)
    utils.save(suggestion_file_path, response)

    print(f"Saved successfully! Location: {suggestion_file_path}")


if __name__ == "__main__":
    main()
