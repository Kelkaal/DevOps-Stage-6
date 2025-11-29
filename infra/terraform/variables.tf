variable "aws_region" {
  description = "The AWS region to deploy resources to."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance."
  type        = string
  default     = "ami-053b0d53c279acc90" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type in us-east-1
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "The name of the AWS key pair to use for SSH access."
  type        = string
  default     = "Theos_boothe"
}