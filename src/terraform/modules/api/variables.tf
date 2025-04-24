variable "vpc_id" {
  description = "VPC ID where resources will be deployed."
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources."
  type        = string
}

variable "account_id" {
  description = "AWS Account ID."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "project" {
  description = "Project name."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "domain_name" {
  description = "Domain name to be used."
  type        = string
}

variable "minimum_task_count" {
  description = "Minimum number of ECS tasks."
  type        = number
}

variable "api_role_arn" {
  description = "ARN of the ECS Task role for API."
  type        = string
}

variable "api_task_execution_role_arn" {
  description = "ARN of the API Task Execution role."
  type        = string
}

variable "api_backup_role_arn" {
  description = "ARN of the Backup management role."
  type        = string
}

variable "api_alb_security_group_id" {
  description = "ID of the ALB security group."
  type        = string
}

variable "api_security_group_id" {
  description = "ID of the API security group."
  type        = string
}

variable "api_db_security_group_id" {
  description = "ID of the PostgreSQL Database security group."
  type        = string
}

variable "elb_aws_account_for_s3" {
  description = "AWS Account ID for ELB logging to S3."
  type        = string
}

variable "notification_email" {
  description = "Email address for alert notifications."
  type        = string
}

variable "rds_monitoring_role_arn" {
  description = "ARN for RDS monitoring role."
  type        = string
}


variable "db_username" {
  description = "データベースのユーザー名"
  type        = string
}

variable "db_password" {
  description = "データベースのパスワード"
  type        = string
}

variable "default_db_name" {
  description = "デフォルトのデータベース名"
  type        = string
}


data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}