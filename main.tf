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

# ---Key Pair for EC2 ---
resource "aws_key_pair" "ec2_key" {
  key_name   = "fintrack-key" 
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "fintrack-key"
  
}

# --- Security Group for SSH Access ---
resource "aws_security_group" "ssh_access" {
  name        = "allow-ssh"
  description = "Allow SSH access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with a specific IP range for better security
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "application_access" {
  name          = "allow-application-access"
  description   = "allow application to be accessed on port 5001"
  vpc_id        = module.vpc.vpc_id

  ingress {
    description = "application port access"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
}



# --- EC2 Module ---
module "ec2" {
  source = "./modules/ec2" # Path to your EC2 module

  name_prefix     = var.name_prefix
  environment     = local.environment
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = module.vpc.public_subnet_ids[0]
  key_name        = "fintrack-key" 
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ssh_access.id, aws_security_group.application_access.id] # Associate the security group

  user_data = file("${path.module}/scripts/user_data.sh") # Path to your user data script

  tags = {
    Role = "WebServer"
  }
}