# DO NOT DELETE MANUALLY. This file is copied to the module directory by scripts/tests/test_init.sh and is used during module testing.
# This file is for testing purposes only and should not be used otherwise.
# It will be deleted by scripts/tests/test_destroy.sh.

terraform {
  required_version = "= 1.10.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.84.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
    }
  }

  profile = "development"
}
