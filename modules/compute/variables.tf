# variables.tf in /modules/compute

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_id_1" {
  description = "The ID of the first public subnet"
  type        = string
}

variable "public_subnet_id_2" {
  description = "The ID of the second public subnet"
  type        = string
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to use for EC2 instances"
  type        = string
}



