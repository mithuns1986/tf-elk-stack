variable "ecr_name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"demo\""
}
variable "product"{
  description = "Product Name"
  default = "CDI"
}
variable "costcenter" {
  description = "AWS Cost Center"
  default = "12345"
}
