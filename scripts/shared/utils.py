# import hcl2
from contextlib import contextmanager
import sys
import os
import re
import subprocess
from datetime import datetime
from typing import Any, Dict, Optional

from jinja2 import Environment, FileSystemLoader
from openai import OpenAI

# configs
IAC_ROOT = os.environ["IAC_ROOT"]
MODULES_DIR = f"{IAC_ROOT}/src/terraform/modules"
DOCUMENTS_DIR = f"{IAC_ROOT}/documents"
SCRIPTS_DIR = f"{IAC_ROOT}/scripts"
HISTORY_DIR = f"{IAC_ROOT}/logs/"
ENVIRONMENT_DIR = f"{IAC_ROOT}/src/terraform"
DEFAULT_REGION = "ap-northeast-1"  # e.g., us-west-2, ap-northeast-1
CHATGPT_MODEL = "gpt-4o"

TRY_COUNT = 1  # 1＝リトライしない。一度目で既存コードを破壊されたらリトライしても直らないため。


# wrapper
def ask(prompt: str) -> str:
    return ask_gpt(prompt)


def ask_gpt(prompt: str) -> str:
    # print("prompt is ...")
    # print(prompt)

    date_str = datetime.now().strftime("%Y%m%d%H%M%S")

    save(HISTORY_DIR + f"{date_str}_prompt.log", prompt)

    client = OpenAI(
        api_key=os.environ.get("OPENAI_API_KEY"),
    )

    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": prompt,
            },
        ],
        model=CHATGPT_MODEL,
    )

    response = chat_completion.choices[0].message.content

    save(HISTORY_DIR + f"{date_str}_response.log", response)
    # print(f"response is {response}.")

    return response


def save(file_path: str, content: str) -> None:
    with open(file_path, "w") as f:
        f.write(content)


def load(file_path: str) -> Optional[str]:
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"file not found at {file_path}")

    with open(file_path, "r") as f:
        return f.read()


def cleaning(code: str) -> str:
    lines = code.splitlines()
    cleaned_lines = []
    in_terraform_block = False
    found_terraform = False

    for line in lines:
        if "```terraform" in line or "```hcl" in line:
            in_terraform_block = True
            found_terraform = True
            continue

        if "```" in line and in_terraform_block:
            in_terraform_block = False
            break

        if in_terraform_block:
            cleaned_lines.append(line)

    if not found_terraform:
        return code.strip()
    return "\n".join(cleaned_lines)


def render(template_path: str, data: Dict[str, Any]) -> str:
    template_dir = os.path.dirname(os.path.abspath(template_path))
    env = Environment(loader=FileSystemLoader(template_dir))

    file_name = os.path.basename(template_path)

    template = env.get_template(file_name)
    return template.render(data)


def get_cli_arg(index: int, default: Optional[str] = None) -> Optional[str]:
    if len(sys.argv) <= index:
        return default

    return sys.argv[index]


def is_special_type(type: str) -> bool:
    return type != "general"


def get_path_prefix(identifier: str, type: str) -> str:
    if is_special_type(type):
        return f"{MODULES_DIR}/{type}/{identifier}_"
    return f"{MODULES_DIR}/{identifier}/"


def get_backup_file_name(terraform_file: str) -> str:
    return f"{terraform_file}.{datetime.now().strftime("%Y%m%d%H%M%S")}.back"


def get_suggestion_file_name(terraform_file: str) -> str:
    return f"{terraform_file}.{datetime.now().strftime("%Y%m%d%H%M%S")}.suggestion"


def extract_tf_contents(text: str) -> tuple[str, str, str]:
    main_contents = []
    variables_contents = []
    outputs_contents = []

    current_section = None

    for line in text.splitlines():

        if line == "## main.tf":
            current_section = "main"
        elif line == "## variables.tf":
            current_section = "variables"
        elif line == "## outputs.tf":
            current_section = "outputs"
        elif line == "---":
            current_section = None
        elif line.startswith("```hcl"):
            continue
        elif line.startswith("```"):
            current_section = None
        elif current_section == "main":
            main_contents.append(line)
        elif current_section == "variables":
            variables_contents.append(line)
        elif current_section == "outputs":
            outputs_contents.append(line)

    main_contents_str = "\n".join(main_contents)
    variables_contents_str = "\n".join(variables_contents)
    outputs_contents_str = "\n".join(outputs_contents)

    return main_contents_str, variables_contents_str, outputs_contents_str


@contextmanager
def error_handler():
    try:
        yield
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
