variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default     = "Dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "vpc_id" {
  description = "vpc_id to create Resources."
  default     = "vpc-0e21ee9348997abe4"
}

variable "private_subnets" {
  description = "a list of private subnets of VPC"
  default     = ["subnet-0e7609d98a69bde2d", "subnet-02c34d808cc6030b8"]
}

variable "public_subnets" {
  description = "a list of public subnets in your VPC"
  default     = ["subnet-045960fe05e0d8d68", "subnet-045960fe05e0d8d68"]
}

variable "service_desired_count" {
  description = "Number of tasks running in parallel"
  default     = 1
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
  default     = "arn:aws:acm:ap-southeast-1:818682305270:certificate/dbb8fa5f-1993-4c29-9c08-5b141d1beb53"
}
variable "container_image" {
  description = "Container Image"
}
variable "es_container_port_mappings" {
  type = list(object({
    hostPort      = number
    containerPort = number
    protocol      = string
  }))
  default = [{
    hostPort      = 9200
    containerPort = 9200
    protocol      = "tcp"
    },
    {
      hostPort      = 9300
      protocol      = "tcp"
      containerPort = 9300
    }
  ]
}
variable "logstash_container_port_mappings" {
  type = list(object({
    hostPort      = number
    containerPort = number
    protocol      = string
  }))
  default = [{
    hostPort      = 5010
    containerPort = 5010
    protocol      = "tcp"
    },
    {
      hostPort      = 8080
      containerPort = 8080
      protocol      = "tcp"
    }
  ]
}
variable "kibana_container_port_mappings" {
  type = list(object({
    hostPort      = number
    containerPort = number
    protocol      = string
  }))
  default = [{
    hostPort      = 5601
    containerPort = 5601
    protocol      = "tcp"
  }]
}
variable "route53_hosted_zone_id" {
}
variable "kibana_container_port" {
  default = "5601"
}
variable "es_container_port" {
  default = "9200"
}
variable "logstah_container_port" {
  default = "8080"
}
variable "domain_name" {
  default = "elk.test.afa-cdi.com"
}
variable "log_group" {
  default = ""
}
