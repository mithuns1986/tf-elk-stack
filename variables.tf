variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default     = "UAT"
}

variable "aws_region" {
  type        = string
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}

#variable "pitstop_name" {
#  description = "Name of the Pitstop"
#}
variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "vpc_id" {
  description = "vpc_id to create Resources."
  default     = "vpc-00e7b000d0c99d2df"
}

variable "private_subnets" {
  description = "a list of private subnets of VPC"
  default     = ["subnet-047545993d4096953", "subnet-030d663053d89719c"]
}

variable "public_subnets" {
  description = "a list of public subnets in your VPC"
  default     = ["subnet-02ccf725374977064", "subnet-06ec5191598b2b502"]
}

variable "service_desired_count" {
  description = "Number of tasks running in parallel"
  default     = 1
}

variable "container_port" {
  description = "The port where the Docker is exposed"
  default     = 4000
}

variable "container_cpu" {
  description = "The number of cpu units used by the task"
  default     = 256
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
  default     = 512
}

variable "health_check_path" {
  description = "Http path for task health check"
  default     = "/"
}

variable "tsl_certificate_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
  default = "arn:aws:acm:ap-southeast-1:818682305270:certificate/dbb8fa5f-1993-4c29-9c08-5b141d1beb53"
}
variable "container_image"{
  description = "Container Image"
}
variable "container_port_mappings" {
  type = list(object({
    hostPort      = number
    containerPort = number
    protocol      = string
  }))
  default = [{
    hostPort      = 4000
    containerPort = 4000
    protocol      = "tcp"
  }]
}
variable "sandbox_container_port_mappings" {
  type = list(object({
    hostPort      = number
    containerPort = number
    protocol      = string
  }))
  default = [{
    hostPort      = 4001
    containerPort = 4001
    protocol      = "tcp"
  }]
}
variable "sg_name"{
  default ="UAT-sg"
}
variable "Participant" {
  description = "Participant name"
  default = "SGTraDex"
}
variable "db_allocated_storage" {
  default = "20GB"
}
variable "db_instance_class" {
  default = "t2.micro"
}
variable "multi_az" {
  default = false
}

variable "database_username" {
  default = ""
}
variable "database_password"{
  default = ""
}
variable "pitstop_db_password" {
  default = "pitstop#4321"
}
variable "pitstop_db_username" {
  default = "pistopuser"
}
#variable "log_group" {}

variable "bitbucket_connection_arn" {}
variable "aws_account" {}
variable "route53_hosted_zone_id" {

}
variable "ecr_name" {

}
#variable "pitstop_license_key" {
# description = "pitstop_license_key to be applied to the applicaton"
#}


variable "ecr_repo_name" {

}




