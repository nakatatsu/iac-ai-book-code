output "api_role_arn" {
  description = "ARN of the API Task role"
  value       = aws_iam_role.api.arn
}

output "api_task_execution_role_arn" {
  description = "ARN of the API Task Execution role"
  value       = aws_iam_role.api_task_execution.arn
}

output "api_backup_role_arn" {
  description = "ARN of the API Backup Management role"
  value       = aws_iam_role.api_backup.arn
}

output "rds_monitoring_role_arn" {
  description = "ARN of the RDS Cluster Monitoring role"
  value       = aws_iam_role.rds_monitoring.arn
}