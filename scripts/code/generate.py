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

    path_prefix = utils.get_path_prefix(identifier, type)

    prompt = utils.render(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), template_file),
        {
            "identifier": identifier,
            "specification": utils.load(f"{path_prefix}specification.md"),
            "project_information": utils.load(f"{utils.DOCUMENTS_DIR}/project_information.md"),
            "coding_guideline": utils.load(f"{utils.DOCUMENTS_DIR}/coding_guidelines.md"),
        },
    )

    response = utils.ask(prompt)
    main_contents, variables_contents, outputs_contents = utils.extract_tf_contents(response)

    utils.save(f"{path_prefix}main.tf", main_contents)
    utils.save(f"{path_prefix}variables.tf", variables_contents)
    utils.save(f"{path_prefix}outputs.tf", outputs_contents)


if __name__ == "__main__":
    main()
