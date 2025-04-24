import os
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))
from shared import utils


def main() -> None:
    if (identifier := utils.get_cli_arg(1)) is None:
        print("Please provide a module name as a command-line argument.")
        sys.exit(1)

    type = utils.get_cli_arg(2, "general")
    template_file = f"{type}.j2"
    requirements_path = f"{utils.MODULES_DIR}/{identifier}/readme.md"
    design_policy_path = f"{utils.DOCUMENTS_DIR}/infrastructure_design_policy.md"

    if type == "general":
        path_prefix = f"{utils.MODULES_DIR}/{identifier}/"
        values = {
            "identifier": identifier,
            "requirements": utils.load(requirements_path),
            "infrastructure_design_policy": utils.load(design_policy_path),
        }
    else:
        path_prefix = f"{utils.MODULES_DIR}/{type}/{identifier}_"
        values = {
            "identifier": identifier,
            "requirements": utils.load(requirements_path),
            "infrastructure_design_policy": utils.load(design_policy_path),
            "main_specifications": utils.load(f"{utils.MODULES_DIR}/{identifier}/specification.md"),
        }

    prompt = utils.render(Path(__file__).parent / template_file, values)
    response = utils.ask(prompt)
    utils.save(f"{path_prefix}specification.md", response)

    print(f"Saved successfully!")


if __name__ == "__main__":
    main()
