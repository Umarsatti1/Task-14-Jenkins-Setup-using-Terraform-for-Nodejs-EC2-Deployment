output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "public_subnet" {
  description = "VPC Public Subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet" {
  description = "VPC Private subnet ID"
  value       = aws_subnet.private.id
}

output "ec2_app_sg_id" {
  description = "Application EC2 Security group ID"
  value       = aws_security_group.ec2_app_sg.id
}

output "ec2_jenkins_sg_id" {
  description = "Jenkins EC2 Security group ID"
  value       = aws_security_group.ec2_jenkins_sg.id
}