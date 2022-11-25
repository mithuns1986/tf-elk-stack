variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "container_port" {
  description = "Ingres and egress port of the container"
}
variable "Participant" {
  description= "Product name"
  default = "SgTraDex"
}
variable "sandbox_container_port" {
  description = "Ingres and egress port of the container"
}
