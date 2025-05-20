locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Terraform   = "true"
      Module      = "vpc"
    },
    var.tags
  )
  num_azs = length(var.availability_zones)
}

#  VPC 
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc-${var.environment}"
  })
}

# Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw-${var.environment}"
  })
}

#  Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % local.num_azs] # Cycle through AZs
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name   = "${var.project_name}-public-subnet-${var.availability_zones[count.index % local.num_azs]}"
    Tier   = "public"
  })
}

# Private Subnets 
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % local.num_azs] # Cycle through AZs
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name   = "${var.project_name}-private-subnet-${var.availability_zones[count.index % local.num_azs]}"
    Tier   = "private"
  })
}

# --- NAT Gateway(s) and EIPs (Optional) ---
# resource "aws_eip" "nat_eip" {
#   count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.num_azs) : 0
#   domain = "vpc" # Changed from 'vpc = true' for newer provider versions

#   tags = merge(local.common_tags, {
#     Name = var.single_nat_gateway ? "${var.project_name}-nat-eip-${var.environment}" : "${var.project_name}-nat-eip-${var.availability_zones[count.index % local.num_azs]}"
#   })
#   depends_on = [aws_internet_gateway.igw]
# }

# resource "aws_nat_gateway" "nat_gw" {
#   count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.num_azs) : 0
#   allocation_id = aws_eip.nat_eip[count.index].id
#   subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id # Place NAT in public subnets round-robin

#   tags = merge(local.common_tags, {
#     Name = var.single_nat_gateway ? "${var.project_name}-nat-gw-${var.environment}" : "${var.project_name}-nat-gw-${var.availability_zones[count.index % local.num_azs]}"
#   })
#   depends_on = [aws_internet_gateway.igw]
# }

#  Public Route Table 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt-${var.environment}"
  })
}

resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# --- Private Route Table(s) ---
# One private route table per AZ if not using a single NAT GW, or one shared private RT.
# resource "aws_route_table" "private_rt" {
#   count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.num_azs) : 1 # Always create at least one "isolated" private RT
#   vpc_id = aws_vpc.main.id

#   dynamic "route" {
#     for_each = var.enable_nat_gateway ? [1] : [] # Only add this route if NAT GW is enabled
#     content {
#       cidr_block     = "0.0.0.0/0"
#       nat_gateway_id = aws_nat_gateway.nat_gw[var.single_nat_gateway ? 0 : count.index].id
#     }
#   }

#   tags = merge(local.common_tags, {
#     Name = var.enable_nat_gateway && !var.single_nat_gateway ? "${var.project_name}-private-rt-${var.availability_zones[count.index % local.num_azs]}" : "${var.project_name}-private-rt-shared"
#   })
# }

# resource "aws_route_table_association" "private_rta" {
#   count          = length(aws_subnet.private)
#   subnet_id      = aws_subnet.private[count.index].id
#   # Associate to the correct private route table:
#   # If single NAT or no NAT, associate to the first (or only) private_rt.
#   # If multiple NATs (one per AZ), associate to the RT corresponding to the subnet's AZ.
#   route_table_id = aws_route_table.private_rt[
#     var.enable_nat_gateway && !var.single_nat_gateway ? (index(var.availability_zones, aws_subnet.private[count.index].availability_zone)) : 0
#   ].id
# }

# Default Network ACL 
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-default-nacl-${var.environment}"
  })
}

#  Default Security Group 
# resource "aws_default_security_group" "default" {
#   vpc_id = aws_vpc.main.id

#   # Allow traffic between resources in this security group
#   ingress {
#     protocol  = -1
#     self      = true
#     from_port = 0
#     to_port   = 0
#   }

#   # Allow inbound access to port 5001 from anywhere (for the application)
#   ingress {
#     protocol    = "tcp"
#     from_port   = 5001
#     to_port     = 5001
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow public access to fintrack application on port 5001"
#   }

#   # Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(local.common_tags, {
#     Name = "${var.project_name}-default-sg-${var.environment}"
#   })
# }