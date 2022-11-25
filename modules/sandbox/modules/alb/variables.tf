variable "alb_name" {
  description = "ALB Name"
}

variable "environment" {
  description = "the name of your environment, e.g. \"demo\""
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "health_check_path" {
  description = "Path to check if the service is healthy, e.g. \"/status\""
}
variable "Participant" {
  description = "Product name"
  default = "SgTraDex"
}
variable "pitstop_name" {}
variable "route53_hosted_zone_id" {

}
variable "aws_alb_listener_https_arn" {
  
}
variable "aws_lb_main_dns_name" {
  
}
variable "aws_lb_main_zone_id" {
  
}
