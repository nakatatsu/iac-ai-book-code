resource "aws_security_group" "alb" {
  name        = "${var.environment}-${var.project}-alb"
  description = "Security group for ALB to allow inbound HTTPS and HTTP requests from the Internet"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-${var.project}-alb"
  }
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS traffic from anywhere"
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP traffic from anywhere"
}

resource "aws_security_group_rule" "alb_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  source_security_group_id = aws_security_group.api.id
  description       = "Allow HTTP traffic to API security group"
}

resource "aws_security_group" "api" {
  name        = "${var.environment}-${var.project}-api"
  description = "Security group for API container"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-${var.project}-api"
  }
}

resource "aws_security_group_rule" "api_ingress_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api.id
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow HTTP traffic from ALB"
}

resource "aws_security_group_rule" "api_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.api.id
  description       = "Allow HTTPS traffic to external services"
}

resource "aws_security_group_rule" "api_egress_postgresql" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.api.id
  source_security_group_id = aws_security_group.db.id
  description       = "Allow PostgreSQL traffic to Aurora DB"
}

resource "aws_security_group" "db" {
  name        = "${var.environment}-${var.project}-db"
  description = "Security group for Aurora DB to allow secure connections from API"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-${var.project}-db"
  }
}

resource "aws_security_group_rule" "db_ingress_postgresql" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.api.id
  description              = "Allow PostgreSQL traffic from API"
}
