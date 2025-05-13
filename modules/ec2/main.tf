locals {
  instance_name = "${var.name_prefix}-ec2-${var.environment}"
  common_tags = merge(
    {
      Name        = local.instance_name
      Environment = var.environment
      Terraform   = "true"
      Module      = "ec2"
    },
    var.tags
  )
}

resource "aws_instance" "this" {
  count = var.create_instance ? 1 : 0 # Conditionally create the instance

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  user_data                   = var.user_data 
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.monitoring
  disable_api_termination     = var.disable_api_termination

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      kms_key_id            = root_block_device.value.kms_key_id
      iops                  = root_block_device.value.iops
      throughput            = root_block_device.value.throughput
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = ebs_block_device.value.encrypted
      kms_key_id            = ebs_block_device.value.kms_key_id
      iops                  = ebs_block_device.value.iops
      throughput            = ebs_block_device.value.throughput
      snapshot_id           = ebs_block_device.value.snapshot_id
    }
  }

  tags = local.common_tags

  
}

