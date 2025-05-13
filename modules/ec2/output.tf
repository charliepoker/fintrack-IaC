output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = var.create_instance ? aws_instance.this[0].id : null
}

output "instance_arn" {
  description = "The ARN of the EC2 instance."
  value       = var.create_instance ? aws_instance.this[0].arn : null
}

output "private_ip" {
  description = "The private IP address of the EC2 instance."
  value       = var.create_instance ? aws_instance.this[0].private_ip : null
}

output "public_ip" {
  description = "The public IP address of the EC2 instance, if applicable."
  value       = var.create_instance ? aws_instance.this[0].public_ip : null
}

output "public_dns" {
  description = "The public DNS name of the EC2 instance, if applicable."
  value       = var.create_instance ? aws_instance.this[0].public_dns : null
}

output "primary_network_interface_id" {
  description = "The ID of the primary network interface."
  value       = var.create_instance ? aws_instance.this[0].primary_network_interface_id : null
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including default tags."
  value       = var.create_instance ? aws_instance.this[0].tags_all : {}
}