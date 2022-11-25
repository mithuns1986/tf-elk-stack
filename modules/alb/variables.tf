variable "alb_name" {
  description = "ALB Name"
}

variable "environment" {
  description = "the name of your environment, e.g. \"demo\""
}

variable "subnets" {
  description = "Comma separated list of subnet IDs"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "alb_security_groups" {
  description = "Comma separated list of security groups"
}

variable "alb_tls_cert_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
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
variable "waf_arn" {}

variable "alb_access_log_bucket" {}