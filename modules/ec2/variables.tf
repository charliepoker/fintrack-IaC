variable "name_prefix" {
  description = "A prefix for the EC2 instance name and other resources."
  type        = string
  default     = "fintrack"
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance. Ensure it's valid for your region."
  type        = string
  # No default, this is usually region-specific and application-specific
  # Users will need to provide this or you can use a data source in the root module
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in."
  type        = string
  # No default, this will come from your VPC module or other network setup
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "The name of the EC2 key pair to allow SSH access. Leave blank if not needed or managed differently."
  type        = string
  default     = null # Using null allows conditional creation of the argument
}

variable "user_data" {
  description = "User data to provide to the instance. This can be a script or cloud-init config."
  type        = string
  default     = null
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with the EC2 instance."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance. Usually true for public subnets."
  type        = bool
  default     = false
}

# variable "root_block_device" {
#   description = "Configuration for the root block device."
#   type = list(object({
#     volume_size           = optional(number, 8)    # Default 8 GB
#     volume_type           = optional(string, "gp3") # Default gp3
#     delete_on_termination = optional(bool, true)
#     encrypted             = optional(bool, false)
#     kms_key_id            = optional(string, null)
#     iops                  = optional(number, null) # For io1, io2, gp3
#     throughput            = optional(number, null) # For gp3
#   }))
#   default = [{}] # Provides default empty object to trigger internal defaults if not specified
# }

# variable "ebs_block_device" {
#   description = "Configuration for additional EBS block devices."
#   type = list(object({
#     device_name           = string
#     volume_size           = optional(number, 8)
#     volume_type           = optional(string, "gp3")
#     delete_on_termination = optional(bool, true)
#     encrypted             = optional(bool, false)
#     kms_key_id            = optional(string, null)
#     iops                  = optional(number, null)
#     throughput            = optional(number, null)
#     snapshot_id           = optional(string, null)
#   }))
#   default = []
# }

variable "monitoring" {
  description = "If true, enables detailed CloudWatch monitoring for the instance. Additional charges may apply."
  type        = bool
  default     = false
}

variable "disable_api_termination" {
  description = "If true, enables EC2 instance termination protection."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of additional tags to assign to the EC2 instance."
  type        = map(string)
  default     = {}
}

variable "create_instance" {
  description = "Whether to create the EC2 instance. Useful for conditional creation."
  type        = bool
  default     = true
}