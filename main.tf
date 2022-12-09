provider "aws" {
  region  = var.aws_region
  version = "~> 4.5.0"
}
terraform {
  backend "s3" {
    region = "ap-southeast-1"
  }
}
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-ELK-cluster"
  tags = {
    Name        = "${var.environment}-ELK-cluster"
    Environment = var.environment
  }
}
module "alb" {
  source                 = "./modules/alb"
  alb_name               = var.environment
  vpc_id                 = var.vpc_id
  subnets                = var.public_subnets
  environment            = var.environment
  alb_security_groups    = [module.security_groups.alb]
  alb_tls_cert_arn       = var.tsl_certificate_arn
  health_check_path      = var.health_check_path
  route53_hosted_zone_id = var.route53_hosted_zone_id
  waf_arn                = var.waf_arn
}

module "iam_policy" {
  source      = "./modules/iam_policy"
  environment = var.environment
}

module "es" {
  source                      = "./modules/es"
  environment                 = var.environment
  region                      = var.aws_region
  subnets                     = var.private_subnets
  task_execution_role_arn     = module.iam_policy.task_execution_role_arn
  ecs_task_role_arn           = module.iam_policy.ecs_task_role_arn
  ecs_service_security_groups = [module.security_groups.es]
  container_port              = var.es_container_port
  container_port_mappings     = var.es_container_port_mappings
  container_cpu               = "1024"
  container_memory            = "2048"
  service_desired_count       = var.service_desired_count
  aws_alb_target_group_arn    = module.alb.es_aws_alb_target_group_arn
  container_environment = [
    { name  = "DISCOVERY_TYPE",
      value = "single-node"
    },
    { name  = "discovery.type",
      value = "single-node"
    },
    { name  = "ELASTIC_PASSWORD",
      value = "SGTelk123!"
    },
    { name  = "ELASTICSEARCH_SKIP_TRANSPORT_TLS",
      value = "true"
    },
    { name  = "ES_JAVA_OPTS",
      value = "-Xms512m -Xmx512m"
    }
  ]
  container_image = var.container_image
}
module "kibana" {
  source                      = "./modules/kibaba"
  environment                 = var.environment
  region                      = var.aws_region
  subnets                     = var.private_subnets
  task_execution_role_arn     = module.iam_policy.task_execution_role_arn
  ecs_task_role_arn           = module.iam_policy.ecs_task_role_arn
  ecs_service_security_groups = [module.security_groups.kibana]
  container_port              = var.kibana_container_port
  container_port_mappings     = var.kibana_container_port_mappings
  container_cpu               = "1024"
  container_memory            = "2048"
  service_desired_count       = var.service_desired_count
  aws_alb_target_group_arn    = module.alb.kibana_aws_alb_target_group_arn
  container_environment = [
    { name  = "KIBANA_SYSTEM_PASSWORD",
      value = "SGTkibana123!"
    },
    {
      name  = "SERVER_PUBLICBASEURL",
      value = "https://kibana.dev.afa-cdi.com"
    }
  ]
  container_image = var.container_image
}
module "logstash" {
  source                      = "./modules/logstash"
  environment                 = var.environment
  region                      = var.aws_region
  subnets                     = var.private_subnets
  task_execution_role_arn     = module.iam_policy.task_execution_role_arn
  ecs_task_role_arn           = module.iam_policy.ecs_task_role_arn
  ecs_service_security_groups = [module.security_groups.logstash]
  container_port              = var.logstash_container_port
  container_port_mappings     = var.logstash_container_port_mappings
  container_cpu               = "1024"
  container_memory            = "2048"
  service_desired_count       = var.service_desired_count
  aws_alb_target_group_arn    = module.alb.logstash_aws_alb_target_group_arn
  container_environment = [
    { name  = "LOGSTASH_ELASTICSEARCH_HOST	",
      value = "http://elk.sgtradex.io:9200"
    },
    {
      name  = "LOGSTASH_INTERNAL_PASSWORD",
      value = "SGTlogstash123!"
    }
  ]
  container_image = var.container_image
}
