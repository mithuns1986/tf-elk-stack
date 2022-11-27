provider "aws" {
  region     = var.aws_region
  version    = "~> 4.5.0"
}

terraform {
  backend "s3" {
    region  = "ap-southeast-1"
  }
}

resource "aws_s3_bucket" "main" {
  bucket = var.environment == "one" ?  "${lower(var.environment)}-elk-bk" : "${lower(var.environment)}-elk-bucket"
  #acl    = "private"
  #enable_s3_public_access_block = false

  tags = {
    Name        = "${lower(var.environment)}-elk-bucket"
    Environment = "${var.environment}"
    
  }
}
resource "aws_s3_bucket_acl" "s3acl" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}
resource "aws_s3_bucket_public_access_block" "s3public" {
  bucket = aws_s3_bucket.main.id

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_logging" "main" {
  bucket = aws_s3_bucket.main.id

  target_bucket = "prod-pitstop-access-logs"
  target_prefix = "log/"
  }
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${aws_s3_bucket.main.id}"

  policy = <<EOF
{ 
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "AllowSSLRequestsOnly",
          "Action": "s3:*",
          "Effect": "Deny",
          "Resource": [
              "${aws_s3_bucket.main.arn}",
              "${aws_s3_bucket.main.arn}/*"
          ],
          "Condition": {
            "Bool": {
              "aws:SecureTransport": "false"
              }
          },
          "Principal": "*"
        }
  ]
}

EOF
}
########################################

module "security_groups" {
  source         = "./modules/security-groups"
  name           = "${var.environment}-${var.pitstop_name}"
  vpc_id         = var.vpc_id
  environment    = var.environment
  container_port = var.container_port
  Participant    = var.pitstop_name
  sandbox_container_port = var.sandbox_container_port

}
module "iam_policy" {
  source       = "./modules/iam_policy"
  pitstop_name                        = var.pitstop_name
  environment                 = var.environment
  log_group                   = var.pitstop_log_group
  aws_account                 = var.aws_account
  sandbox_log_group           = var.sandbox_pitstop_log_group
}

module "alb" {
  source              = "./modules/alb"
  alb_name            = "${var.environment}-${var.pitstop_name}"
  pitstop_name        = var.pitstop_name
  vpc_id              = var.vpc_id
  subnets             = var.public_subnets
  environment         = var.environment
  alb_security_groups = [module.security_groups.alb]
  alb_tls_cert_arn    = var.tsl_certificate_arn
  health_check_path   = var.health_check_path
  Participant         = var.pitstop_name
  route53_hosted_zone_id = var.route53_hosted_zone_id
  waf_arn               = var.waf_arn
  alb_access_log_bucket = var.alb_access_log_bucket
}
module "codepipeline" {
  source = "./modules/pipeline"
  name                     = var.pitstop_name
  environment              = var.environment
  bitbucket_connection_arn = var.bitbucket_connection_arn
  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name
  ecr_name     = var.ecr_name
}
module "deployment" {
  source = "./modules/deployment"
  ecr_repo_name = var.ecr_repo_name
  name   = "${var.environment}-${var.pitstop_name}"
  codepipeline_name = module.codepipeline.codepipeline_name
  codepipeline_arn  = module.codepipeline.codepipeline_arn
  codepipeline_role_arn = module.codepipeline.codepipeline_role_arn
}
#module "ecr" {
#  source      = "./modules/ecr"
#  ecr_name        = "${var.environment}-pitstop-ECR"
#  environment = var.environment
#}
  # resource "aws_cloudwatch_log_group" "loggroup" {
  #   name = "${var.environment}-${var.pitstop_name}-loggroup"
  #   retention_in_days = "30"

#   tags = {
#     Name        = "${var.environment}-${var.pitstop_name}-loggroup"
#     Environment = var.environment
#     Participant = var.pitstop_name
#   }
# }
#module "rds" {
 # source   = "./modules/rds"
 # environment  = var.environment
 # pitstop_name = var.pitstop_name
 # subnet_ids   = var.private_subnets
 # Participant    = var.pitstop_name
 # allocated_storage = var.db_allocated_storage
 # instance_class = var.db_instance_class
 # multi_az       = var.multi_az
 # database_name  = var.database_name
 # database_username = var.database_username
 # database_password = var.database_password
 # aws_security_group_rds_sg = [module.security_groups.rds_sg]
 # kms_key_id = var.kms_key_id
 # db_engine_version = var.db_engine_version
#}
#module "secretsmanager" {
#  source = "./modules/secretsmanager"
#  name                     = var.pitstop_name
#  environment              = var.environment
#  typeorm_password         = var.database_password
#  pitstop_license_key      = var.pitstop_license_key
#  }
# Enable waf module once in each environment bcz same waf acl can be used to assosiate multiple alb and api
# module "waf" {
#   source = "./modules/waf"
#   environment = var.environment
# }

module "ecs" {
  source                      = "./modules/ecs"
  ecs_name                    = "${var.environment}-${var.pitstop_name}"
  name                        = "${var.environment}-${var.pitstop_name}"
  environment                 = var.environment
  region                      = var.aws_region
  subnets                     = var.private_subnets
  task_execution_role_arn     = module.iam_policy.task_execution_role_arn
  ecs_task_role_arn           = module.iam_policy.ecs_task_role_arn
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
    { name = "ADMIN_CORE_HOST",
    value = "${var.admin_host}"
    },
    { name = "PORT",
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
      name = "AWS_S3_BUCKET"
      value = aws_s3_bucket.main.id
    },
    {
      name = "HIGHWAY_HOST",
      value = "${var.highway_host}"
    },
    {
      name = "HIGHWAY_REQUEST_ENDPOINT",
      value = "latest/api/v1/data"
    },
    {
      name = "LOG_APPENDERS",
      value = "cloudwatch"
    },
    {
      name = "NODE_ENV",
      value = "${var.environment}"
    },
    {
      name = "SERVICE_NAME",
      value = "${var.environment}-${var.pitstop_name}-service"
    },
    {
      name = "TYPEORM_CONNECTION",
      value = "postgres"
    },
    {
      name = "TYPEORM_DATABASE",
      value = "${lower(var.pitstop_name)}db"
    },
    {
      name = "TYPEORM_HOST",
      value = module.rds.rds_address
    },
    {
      name = "TYPEORM_PORT",
      value = "5432"
    },
    {
      name = "TYPEORM_USERNAME",
      value = "${var.database_username}"
    },
    {
      name = "KEY_HOST"
      value = var.key_host
    },
    {
      name = "PITSTOP_URL"
      value = "https://${lower(var.pitstop_name)}.pitstop.sgtradex.io"
    },
    {
      name = "ATTACHMENT_PROXY_URL"
      value = var.attachment_proxy_url
    },
    {
      name = "LOG_LEVEL"
      value = "debug"
    },
    {
      name = "CDI_ENV"
      value = "${lower(var.environment)}"
    },
    {
      name = "ACCESS_FROM_SECRET_MANAGER"
      value = var.secrets_manager_access
    },
    {
      name = "AWS_SECRET_KEY"
      value = module.secretsmanager.secret_key_name
    },
    {
      name = "SENSITIVE_KEYS"
      value = var.sensitive_keys
    }
  ]

  container_image        = var.container_image
  container_port_mappings = var.container_port_mappings
}
module "sandbox" {
  source = "./modules/sandbox"
  #   depends_on = [
  #   module.ecs,
  # ]
  alb_name            = "${var.environment}-${var.pitstop_name}"
  pitstop_name        = var.pitstop_name
  vpc_id              = var.vpc_id
  environment         = var.environment
  health_check_path   = var.health_check_path
  Participant         = var.pitstop_name
  route53_hosted_zone_id = var.route53_hosted_zone_id
  aws_alb_listener_https_arn = module.alb.aws_alb_listner_arn
  aws_lb_main_dns_name = module.alb.aws_lb_main_dns_name
  aws_lb_main_zone_id = module.alb.aws_lb_main_zone_id
  ecs_name                    = "${var.environment}-${var.pitstop_name}"
  name                        = "${var.environment}-${var.pitstop_name}"
  region                      = var.aws_region
  subnets                     = var.private_subnets
  task_execution_role_arn     = module.iam_policy.task_execution_role_arn
  ecs_task_role_arn           = module.iam_policy.ecs_task_role_arn
  ecs_service_security_groups = [module.security_groups.ecs_tasks]
  sandbox_container_port      = var.sandbox_container_port
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  service_desired_count       = var.service_desired_count
  log_group                   = var.sandbox_pitstop_log_group
  container_environment = [
    { name = "ADMIN_CORE_HOST",
    value = "${var.sandbox_admin_host}"
    },
    { name = "PORT",
    value = var.sandbox_container_port
    },
    {
      name  = "ADMIN_CORE_PITSTOPCONFIG_ENDPOINT",
      value = "config/"
    },
    {
      name  = "AWS_CLOUDWATCH_LOG_GROUP",
      value = var.sandbox_pitstop_log_group
    },
    {
      name  = "AWS_REGION",
      value = "${var.aws_region}"

    },
    {
      name = "AWS_S3_BUCKET"
      value = aws_s3_bucket.main.id
    },
    {
      name = "HIGHWAY_HOST",
      value = "${var.sandbox_highway_host}"
    },
    {
      name = "HIGHWAY_REQUEST_ENDPOINT",
      value = "latest/api/v1/data"
    },
    {
      name = "LOG_APPENDERS",
      value = "cloudwatch"
    },
    {
      name = "NODE_ENV",
      value = "${var.environment}"
    },
    {
      name = "SERVICE_NAME",
      value = "sandbox-${var.environment}-${var.pitstop_name}-service"
    },
    {
      name = "TYPEORM_CONNECTION",
      value = "postgres"
    },
    {
      name = "TYPEORM_DATABASE",
      value = "sandbox${lower(var.pitstop_name)}db"
    },
    {
      name = "TYPEORM_HOST",
      value = module.rds.rds_address
    },
    {
      name = "TYPEORM_PORT",
      value = "5432"
    },
    {
      name = "TYPEORM_USERNAME",
      value = "${var.sandbox_database_username}"
    },
    {
      name = "KEY_HOST"
      value = var.sandbox_key_host
    },
    {
      name = "PITSTOP_URL"
      value = "https://${lower(var.pitstop_name)}.pitstop.sgtradex.io"
    },
    {
      name = "ATTACHMENT_PROXY_URL"
      value = var.attachment_proxy_url
    },
    {
      name = "LOG_LEVEL"
      value = "debug"
    },
    {
      name = "CDI_ENV"
      value = "${lower(var.environment)}"
    },
    {
      name = "ACCESS_FROM_SECRET_MANAGER"
      value = var.secrets_manager_access
    },
    {
      name = "AWS_SECRET_KEY"
      value = "sandbox-${var.environment}-${var.pitstop_name}-sg-secretsManager"
    },
    {
      name = "SENSITIVE_KEYS"
      value = var.sensitive_keys
    }
  ]
  container_image        = var.container_image
  sandbox_container_port_mappings = var.sandbox_container_port_mappings
  sandbox_database_username = var.sandbox_database_username
  sandbox_database_name = "sandbox${lower(var.pitstop_name)}db"
  sandbox_database_password = var.sandbox_database_password
  aws_ecs_cluster_main_id = module.ecs.cluster_id
  db_host = module.rds.rds_address
  database_name  = var.database_name
  database_username = var.database_username
  database_password = var.database_password
  sandbox_typeorm_password    = var.sandbox_database_password
  sandbox_pitstop_license_key = var.sandbox_pitstop_license_key
  ecs_cluster_name = module.ecs.cluster_name
}