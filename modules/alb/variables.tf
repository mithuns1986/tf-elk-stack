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
variable "domain_name" {
  default = ""
}
