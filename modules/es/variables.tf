variable "ecs_name" {
  description = "the name of your stack, e.g. \"demo\""
}
variable "name" {}
variable "Participant" {
  default = "SgTraDex"
}
variable "task_execution_role_arn" {}
variable "ecs_task_role_arn" {}

variable "environment" {
  description = "the name of your environment, e.g. \"demo\""
}
variable "log_group"{
  description = "AWS Log group"
}

variable "region" {
  description = "the AWS region in which resources are created"
}

variable "subnets" {
  description = "List of subnet IDs"
}

variable "ecs_service_security_groups" {
  description = "Comma separated list of security groups"
}

variable "container_port" {
  description = "Port of container"
}

variable "container_cpu" {
  description = "The number of cpu units used by the task"
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
}

variable "container_image" {
  description = "Docker image to be launched"
}

variable "aws_alb_target_group_arn" {
  description = "ARN of the alb target group"
}

variable "service_desired_count" {
  description = "Number of services running in parallel"
}

variable "container_environment" {
  description = "The container environmnent variables"
  type        = list
}

variable "container_port_mappings"{

}
variable "product" {
  description= "Product name"
  default = "CDI"
}
variable "costcenter"{
  description = "AWS Cost center"
  default = "12345"
}

