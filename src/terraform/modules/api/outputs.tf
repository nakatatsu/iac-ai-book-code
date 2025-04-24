output "alb_arn" {
  description = "ARN of the created Application Load Balancer."
  value       = aws_alb.api.arn
}