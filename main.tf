# FinTrack Infrastructure as Code
# Main configuration file

# --- Variables for all modules ---
locals {
  project_name = "fintrack"
  environment  = "dev"
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "Obinna"
  }
}

# --- VPC Module ---
module "vpc" {
  source = "./modules/vpc"

  # Project information
  project_name = local.project_name
  environment  = local.environment

  # VPC Configuration
  vpc_cidr_block       = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b"]

  # NAT Gateway configuration
  enable_nat_gateway = true
  single_nat_gateway = false # One NAT Gateway per AZ for high availability

  # Additional tags
  tags = local.common_tags
}

# --- Outputs ---
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.vpc.availability_zones_used
}

output "nat_gateway_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}