import os
import sys
import datetime

from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))
from shared import utils


def main() -> None:
    if (input_file := utils.get_cli_arg(1)) is None:
        print("Please provide the input file name as a command-line argument.")
        sys.exit(1)

    if (template_file := utils.get_cli_arg(2)) is None:
        print("Please provide the template file name as a command-line argument.")
        sys.exit(1)

    if (output_file := utils.get_cli_arg(3)) is None:
        print("Please provide the output file name as a command-line argument.")
        sys.exit(1)

    input_content = utils.load(input_file)
    prompt = utils.render(template_file, {"value": input_content})
    response = utils.ask(prompt)
    utils.save(output_file, response)
    print(f"Generated response and saved to {output_file}")


if __name__ == "__main__":
    main()
