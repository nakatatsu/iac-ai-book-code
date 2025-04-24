plugin "aws" {
    enabled = true
    deep_check = true
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
    version = "0.33.0"
}

rule "terraform_typed_variables" {
  enabled = false
}

rule "terraform_naming_convention" {
  enabled     = true
  format      = "snake_case"
}

rule "terraform_required_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}