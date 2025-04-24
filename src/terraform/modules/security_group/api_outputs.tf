output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "api_security_group_id" {
  description = "ID of the API security group"
  value       = aws_security_group.api.id
}

output "db_security_group_id" {
  description = "ID of the Aurora DB security group"
  value       = aws_security_group.db.id
}
