data "aws_caller_identity" "current" {}

variable "region" {
  description = "The AWS region to deploy the resources in"
  type        = string
}

variable "project" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment for resource deployment"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the application"
  type        = string
}

variable "minimum_task_count" {
  description = "Minimum number of ECS tasks"
  type        = number
}

variable "db_username" {
  description = "Database username stored in SSM"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password stored in SSM"
  type        = string
  sensitive   = true
}

variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
  sensitive   = true
}

variable "elb_aws_account_for_s3" {
  description = "S3バケットポリシーに利用するElastic Load Balancing AWS アカウントID"
  type        = string
}

variable "default_db_name" {
  description = "Default database name"
  type        = string
}
