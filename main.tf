provider "aws" {
  region  = var.aws_region
  version = "~> 4.5.0"
}
#dummy comit
terraform {
  backend "s3" {
    region = "ap-southeast-1"
  }
}

module "alb" {
  source                 = "./modules/alb"
  alb_name               = "${var.environment}-${var.pitstop_name}"
  pitstop_name           = var.pitstop_name
  vpc_id                 = var.vpc_id
  subnets                = var.public_subnets
  environment            = var.environment
  alb_security_groups    = [module.security_groups.alb]
  alb_tls_cert_arn       = var.tsl_certificate_arn
  health_check_path      = var.health_check_path
  Participant            = var.pitstop_name
  route53_hosted_zone_id = var.route53_hosted_zone_id
  waf_arn                = var.waf_arn
  alb_access_log_bucket  = var.alb_access_log_bucket

}
module "es" {
  source = "./modules/es"
}

module "logstash" {
  source = "./modules/logstash"
}

module "kibana" {
  source = "./modules/kibana"
}

module "ecs" {
  source                  = "./modules/ecs"
  ecs_name                = "${var.environment}-${var.pitstop_name}"
  name                    = "${var.environment}-${var.pitstop_name}"
  environment             = var.environment
  region                  = var.aws_region
  subnets                 = var.private_subnets
  task_execution_role_arn = module.iam_policy.task_execution_role_arn
  ecs_task_role_arn       = module.iam_policy.ecs_task_role_arn
  # aws_alb_target_group_arn    = module.alb.aws_alb_target_group_arn
  ecs_service_security_groups = [module.security_groups.ecs_tasks]
  container_port              = var.container_port
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  service_desired_count       = var.service_desired_count
  log_group                   = var.pitstop_log_group
  aws_alb_target_group_arn    = module.alb.aws_alb_target_group_arn
  depends_on = [
    module.secretsmanager,
  ]
  container_environment = [
    { name  = "ADMIN_CORE_HOST",
      value = "${var.admin_host}"
    },
    { name  = "PORT",
      value = var.container_port
    },
    {
      name  = "ADMIN_CORE_PITSTOPCONFIG_ENDPOINT",
      value = "config/"
    },
    {
      name  = "AWS_CLOUDWATCH_LOG_GROUP",
      value = var.pitstop_log_group
    },
    {
      name  = "AWS_REGION",
      value = "${var.aws_region}"

    },
    {
      name  = "AWS_S3_BUCKET"
      value = aws_s3_bucket.main.id
    },
    {
      name  = "HIGHWAY_HOST",
      value = "${var.highway_host}"
    },
    {
      name  = "HIGHWAY_REQUEST_ENDPOINT",
      value = "latest/api/v1/data"
    },
    {
      name  = "LOG_APPENDERS",
      value = "cloudwatch"
    },
    {
      name  = "NODE_ENV",
      value = "${var.environment}"
    },
    {
      name  = "SERVICE_NAME",
      value = "${var.environment}-${var.pitstop_name}-service"
    },
    {
      name  = "TYPEORM_CONNECTION",
      value = "postgres"
    },
    {
      name  = "TYPEORM_DATABASE",
      value = "${lower(var.pitstop_name)}db"
    },
    {
      name  = "TYPEORM_HOST",
      value = module.rds.rds_address
    },
    {
      name  = "TYPEORM_PORT",
      value = "5432"
    },
    {
      name  = "TYPEORM_USERNAME",
      value = "${var.database_username}"
    },
    {
      name  = "KEY_HOST"
      value = var.key_host
    },
    {
      name  = "PITSTOP_URL"
      value = "https://${lower(var.pitstop_name)}.pitstop.sgtradex.io"
    },
    {
      name  = "ATTACHMENT_PROXY_URL"
      value = var.attachment_proxy_url
    },
    {
      name  = "LOG_LEVEL"
      value = "debug"
    },
    {
      name  = "CDI_ENV"
      value = "${lower(var.environment)}"
    },
    {
      name  = "ACCESS_FROM_SECRET_MANAGER"
      value = var.secrets_manager_access
    },
    {
      name  = "AWS_SECRET_KEY"
      value = module.secretsmanager.secret_key_name
    },
    {
      name  = "SENSITIVE_KEYS"
      value = var.sensitive_keys
    }
  ]

  container_image         = var.container_image
  container_port_mappings = var.container_port_mappings
}
