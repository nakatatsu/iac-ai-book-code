import os
import sys

from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))
from shared import utils


def main() -> None:
    if (identifier := utils.get_cli_arg(1)) is None:
        print("Please provide a module name as a command-line argument.")
        sys.exit(1)

    if (output := utils.get_cli_arg(2)) is None:
        output = f"{utils.MODULES_DIR}/{identifier}"
        print(f"Output set to modules directory ({output})")

    purpose = input("Please enter the project purpose in one line: ")

    prompt = utils.render(
        f"{utils.SCRIPTS_DIR}/requirements/general.j2",
        {
            "identifier": identifier,
            "purpose": purpose,
        },
    )

    response = utils.ask(prompt)

    utils.save(f"{output}/readme.md", response)

    print(f"Generated requirements and saved to {output}/readme.md")


if __name__ == "__main__":
    main()
