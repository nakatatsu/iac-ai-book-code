resource "aws_acm_certificate" "api" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation : record.fqdn]
}

resource "aws_alb" "api" {
  name                       = "${var.environment}-${var.project}-api"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.api_alb_security_group_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = true
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.logs.bucket
    prefix  = "${var.environment}-${var.project}-api-alb-logs"
    enabled = true
  }
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "${var.environment}-${var.project}-api-scale-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 600
    scale_out_cooldown = 120
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = var.minimum_task_count
  resource_id        = "service/${aws_ecs_cluster.api_cluster.name}/${aws_ecs_service.api_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_backup_plan" "api_rds" {
  name = "${var.environment}-${var.project}-api-rds"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.rds_backup_vault.name
    schedule          = "cron(0 12 * * ? *)"
    lifecycle {
      delete_after = 30
    }
  }
  rule {
    rule_name         = "monthly-backup"
    target_vault_name = aws_backup_vault.rds_backup_vault.name
    schedule          = "cron(0 12 1 * ? *)"
    lifecycle {
      delete_after = 365
    }
  }
}

resource "aws_backup_selection" "rds_backup_selection" {
  iam_role_arn = var.api_backup_role_arn
  name         = "${var.environment}-${var.project}-api-rds-backup-selection"
  plan_id      = aws_backup_plan.api_rds.id

  resources = [
    aws_rds_cluster.api_db.arn
  ]
}

resource "aws_backup_vault_policy" "rds_backup_vault_policy" {
  backup_vault_name = aws_backup_vault.rds_backup_vault.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "backup:DeleteBackupVault",
        "backup:DeleteBackupVaultAccessPolicy",
        "backup:DeleteRecoveryPoint"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_backup_vault" "rds_backup_vault" {
  name = "${var.environment}-${var.project}-api-rds-backup-vault"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/aws/ecs/${var.environment}-${var.project}-api"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "ErrorFilter"
  log_group_name = aws_cloudwatch_log_group.ecs_log_group.name
  pattern        = "\"[Error]\""

  metric_transformation {
    name      = "ErrorCount"
    namespace = "${var.environment}-${var.project}-api"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_error_alarm" {
  alarm_name          = "${var.environment}-${var.project}-api-error-alarm"
  alarm_description   = "Alarm for ECS Error"
  metric_name         = "ErrorCount"
  treat_missing_data  = "notBreaching"
  namespace           = "${var.environment}-${var.project}-api"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  datapoints_to_alarm = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.api_sns.arn]
  ok_actions          = [aws_sns_topic.api_sns.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name = "${var.environment}-${var.project}-api-high-cpu-alarm"

  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.api_sns.arn]
  ok_actions          = [aws_sns_topic.api_sns.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.api_cluster.name
    ServiceName = aws_ecs_service.api_service.name
  }
}

resource "aws_db_subnet_group" "aurora_subnets" {
  name       = "${var.environment}-${var.project}-api"
  subnet_ids = var.private_subnet_ids
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the latest 30 images and delete older ones"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_repository" "api" {
  name = "${var.environment}-${var.project}-api"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecs_cluster" "api_cluster" {
  name = "${var.environment}-${var.project}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "api_service" {
  name            = "${var.environment}-${var.project}-api"
  cluster         = aws_ecs_cluster.api_cluster.id
  task_definition = aws_ecs_task_definition.api_task.arn
  desired_count   = var.minimum_task_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.api_security_group_id]
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  platform_version                   = "LATEST" # Updated to ensure ECS Fargate services use the latest platform version
  health_check_grace_period_seconds  = 300

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

resource "aws_ecs_task_definition" "api_task" {
  family                   = "${var.environment}-${var.project}-api"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = var.api_task_execution_role_arn
  skip_destroy             = true

  container_definitions = jsonencode([
    {
      name                   = "api"
      image                  = "python:latest"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      command     = ["python", "-m", "http.server", "80"]
      taskRoleArn = var.api_role_arn
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "api"
        }
      }
      environment = [
        {
          name  = "DB_HOST"
          value = aws_rds_cluster.api_db.endpoint
        },
        {
          name  = "DB_NAME"
          value = var.default_db_name
        },
        {
          name  = "DB_PORT"
          value = "5432"
        }
      ]
      secrets = [
        {
          name      = "DB_USER"
          valueFrom = aws_ssm_parameter.db_username.arn
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_ssm_parameter.db_password.arn
        }
      ]
    }
  ])
}

resource "aws_kms_alias" "api_cmk" {
  name          = "alias/${var.environment}-${var.project}-api"
  target_key_id = aws_kms_key.api_cmk.id
}

resource "aws_kms_key" "api_cmk" {
  description         = "KMS key for API"
  key_usage           = "ENCRYPT_DECRYPT"
  is_enabled          = true
  enable_key_rotation = true
}

resource "aws_kms_key_policy" "api_cmk" {
  key_id = aws_kms_key.api_cmk.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch"
        Effect = "Allow"
        Principal = {
          "Service" : "cloudwatch.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.api.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.api.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group" "api" {
  name        = "${var.environment}-${var.project}-api"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_rds_cluster" "api_db" {
  cluster_identifier = "${var.environment}-${var.project}-api"
  engine             = "aurora-postgresql"
  engine_version     = "16.4"
  engine_mode        = "provisioned"

  db_subnet_group_name   = aws_db_subnet_group.aurora_subnets.name
  vpc_security_group_ids = [var.api_db_security_group_id]

  master_username              = var.db_username
  master_password              = var.db_password
  database_name                = var.default_db_name
  copy_tags_to_snapshot        = true
  deletion_protection          = true
  storage_encrypted            = true
  preferred_maintenance_window = "tue:05:00-tue:09:00"

  serverlessv2_scaling_configuration {
    min_capacity = 0
    max_capacity = 64
  }
}

resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier                 = "${var.environment}-${var.project}-api-instance"
  cluster_identifier         = aws_rds_cluster.api_db.id
  instance_class             = "db.serverless"
  engine                     = aws_rds_cluster.api_db.engine
  engine_version             = aws_rds_cluster.api_db.engine_version
  publicly_accessible        = false
  auto_minor_version_upgrade = false
  force_destroy              = false
  promotion_tier             = 1

  monitoring_interval                   = 60
  monitoring_role_arn                   = var.rds_monitoring_role_arn
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  lifecycle {
    ignore_changes = [
      promotion_tier
    ]
  }
}

resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_route53_record" "api_dns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_alb.api.dns_name
    zone_id                = aws_alb.api.zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = 365
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-${var.project}-api-logs"
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.elb_aws_account_for_s3}:root"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.logs.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "logs_public_access_block" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs_versioning" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_sns_topic" "api_sns" {
  name = "${var.environment}-${var.project}-alerts"
  kms_master_key_id = aws_kms_key.api_cmk.id
}

resource "aws_sns_topic_policy" "api_sns_policy" {
  arn = aws_sns_topic.api_sns.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.api_sns.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "api_sns_subscription" {
  topic_arn = aws_sns_topic.api_sns.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.environment}/${var.project}/api/db_password"
  type  = "SecureString"
  value = var.db_password
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.environment}/${var.project}/api/db_username"
  type  = "SecureString"
  value = var.db_username
}

