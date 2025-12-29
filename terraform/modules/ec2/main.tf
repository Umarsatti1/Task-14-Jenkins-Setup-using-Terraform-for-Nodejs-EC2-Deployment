locals {
  servers = {
    app-ec2 = {
      name                        = var.ec2_app_name
      ami                         = var.ami_id
      instance_type               = var.instance_type
      availability_az             = var.instance_az
      subnet_id                   = var.public_subnet
      security_group              = var.ec2_app_sg
      key_name                    = var.keypair
      associate_public_ip_address = true
      user_data                   = file("${path.root}/app_ec2.sh")
    }

    jenkins-ec2 = {
      name                        = var.ec2_jenkins_name
      ami                         = var.ami_id
      instance_type               = var.instance_type
      availability_az             = var.instance_az
      subnet_id                   = var.private_subnet
      security_group              = var.ec2_jenkins_sg
      key_name                    = null
      associate_public_ip_address = false
      user_data                   = file("${path.root}/jenkins_ec2.sh")
    }
  }
}

resource "aws_instance" "ec2" {
  for_each = local.servers

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  availability_zone           = each.value.availability_az
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [each.value.security_group]
  key_name                    = each.value.key_name
  associate_public_ip_address = each.value.associate_public_ip_address
  iam_instance_profile        = var.instance_profile
  user_data                   = each.value.user_data

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name = each.value.name
  }
}