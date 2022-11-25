module "db_user" {
    source = "./modules/db_user"
    sandbox_database_password = var.sandbox_database_password
    sandbox_database_username = var.sandbox_database_username
    db_host = var.db_host
    sandbox_database_name = var.sandbox_database_name
    database_username  = var.database_username
    database_password = var.database_password
  
}

module "sandbox_alb" {
  source = "./modules/alb"
  alb_name            = var.alb_name
  pitstop_name        = var.pitstop_name
  vpc_id              = var.vpc_id
  environment         = var.environment
  health_check_path   = var.health_check_path
  Participant         = var.pitstop_name
  route53_hosted_zone_id = var.route53_hosted_zone_id
  aws_alb_listener_https_arn = var.aws_alb_listener_https_arn
  aws_lb_main_dns_name = var.aws_lb_main_dns_name
  aws_lb_main_zone_id  = var.aws_lb_main_zone_id
}
module "sandbox_secretsmanager" {
    source = "./modules/secretsmanager"
    sandbox_pitstop_license_key = var.sandbox_pitstop_license_key
    sandbox_typeorm_password = var.sandbox_typeorm_password
    environment = var.environment
    name = var.pitstop_name
  
}
module "sandbox_ecs" {
  source = "./modules/ecs"
  aws_alb_target_group_arn    = module.sandbox_alb.sandbox_aws_alb_target_group_arn
  ecs_name                    = var.ecs_name
  name                        = var.name
  region                      = var.region
  subnets                     = var.subnets
  task_execution_role_arn     = var.task_execution_role_arn
  ecs_task_role_arn           = var.ecs_task_role_arn
  ecs_service_security_groups = var.ecs_service_security_groups
  sandbox_container_port      = var.sandbox_container_port
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  service_desired_count       = var.service_desired_count
  log_group                   = var.log_group
  container_environment       = var.container_environment
  aws_ecs_cluster_main_id     = var.aws_ecs_cluster_main_id
  sandbox_container_port_mappings = var.sandbox_container_port_mappings
  Participant                 = var.Participant
  container_image             = var.container_image
  environment = var.environment
  ecs_cluster_name = var.ecs_cluster_name
}