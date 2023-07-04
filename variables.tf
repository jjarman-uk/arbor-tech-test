variable "environment" {
  type        = string
  description = "Environment"
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of public subnets inside the VPC"
}

variable "private_subnets" {
  type        = list(string)
  description = "A list of private subnets inside the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for VPC"
}
