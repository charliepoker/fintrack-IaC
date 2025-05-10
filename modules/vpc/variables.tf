variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
  default     = "fintrack"
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "vpc_cidr_block" {
  description = "CIDR block for Fintrack Application VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true 
}

variable "single_nat_gateway" {
  description = "If true and enable_nat_gateway is true, provisions a single NAT Gateway. If false, one per AZ."
  type        = bool
  default     = false # More resilient, but more expensive
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

