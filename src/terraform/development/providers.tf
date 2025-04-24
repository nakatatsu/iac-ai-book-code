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
