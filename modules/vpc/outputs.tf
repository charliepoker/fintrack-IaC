output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets."
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs_out" {
  description = "List of CIDR blocks of public subnets."
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs_out" {
  description = "List of CIDR blocks of private subnets."
  value       = aws_subnet.private[*].cidr_block
}

output "availability_zones_used" {
  description = "List of Availability Zones used by the subnets."
  value       = var.availability_zones # This reflects the input, but useful to output
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = aws_route_table.public_rt.id
}

# output "private_route_table_ids" {
#   description = "List of IDs of private route tables."
#   value       = aws_route_table.private_rt[*].id
# }

# output "nat_gateway_public_ips" {
#   description = "List of public EIPs for the NAT Gateway(s) (if enabled)."
#   value       = var.enable_nat_gateway ? aws_eip.nat_eip[*].public_ip : []
# }
output "nat_gateway_public_ips" {
  description = "List of public EIPs for the NAT Gateway(s) (if enabled)."
  value       = var.enable_nat_gateway 
}

# output "nat_gateway_ids" {
#   description = "List of IDs of the NAT Gateway(s) (if enabled)."
#   value       = var.enable_nat_gateway ? aws_nat_gateway.nat_gw[*].id : []
# }

output "default_network_acl_id" {
  description = "The ID of the default Network ACL for the VPC."
  value       = aws_vpc.main.default_network_acl_id
}

# output "default_security_group_id" {
#   description = "The ID of the default Security Group for the VPC."
#   value       = aws_vpc.main.default_security_group_id
# }