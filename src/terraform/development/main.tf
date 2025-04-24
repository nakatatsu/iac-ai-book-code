module "networking" {
  source         = "../modules/networking"
  region         = var.region
  project        = var.project
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
}

module "iam" {
  source      = "../modules/iam"
  environment = var.environment
  project     = var.project
}

module "security_group" {
  source      = "../modules/security_group"
  environment = var.environment
  project     = var.project
  vpc_id      = module.networking.vpc_id
}

module "api" {
  source                      = "../modules/api"
  environment                 = var.environment
  region                      = var.region
  project                     = var.project
  vpc_id                      = module.networking.vpc_id
  public_subnet_ids           = module.networking.public_subnet_ids
  private_subnet_ids          = module.networking.private_subnet_ids
  domain_name                 = var.domain_name
  minimum_task_count          = var.minimum_task_count
  db_username                 = var.db_username
  db_password                 = var.db_password
  notification_email          = var.notification_email
  elb_aws_account_for_s3      = var.elb_aws_account_for_s3
  default_db_name             = var.default_db_name
  account_id                  = data.aws_caller_identity.current.account_id
  api_alb_security_group_id   = module.security_group.alb_security_group_id
  api_security_group_id       = module.security_group.api_security_group_id
  api_db_security_group_id    = module.security_group.db_security_group_id
  api_role_arn                = module.iam.api_role_arn
  api_backup_role_arn         = module.iam.api_backup_role_arn
  rds_monitoring_role_arn     = module.iam.rds_monitoring_role_arn
  api_task_execution_role_arn = module.iam.api_task_execution_role_arn
}

