variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance. Ensure it's valid for your region."
  type        = string
}

variable "name_prefix" {
  description = "A prefix for the EC2 instance name and other resources."
  type        = string
  default     = "fintrack" 
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}

