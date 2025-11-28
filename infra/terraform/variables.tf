# variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance (e.g., Ubuntu 22.04 LTS)."
  type        = string
  default     = "ami-053b0d53c279acc90" # Ubuntu Server 22.04 LTS (HVM) in us-east-1
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "The name of the AWS EC2 Key Pair for SSH access."
  type        = string
  default     = "Theos_boothe"
}

variable "vpc_id" {
  description = "The VPC ID to deploy into."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The Subnet ID to deploy into."
  type        = string
  default     = null
}
