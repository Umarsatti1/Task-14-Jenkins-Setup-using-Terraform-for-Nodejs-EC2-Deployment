output "instance_ips" {
  value       = { for i, instance in aws_instance.ec2 : i => instance.private_ip }
  description = "Private IPv4 address of EC2 instances using maps"
}

output "instance_ids" {
  value       = { for i, instance in aws_instance.ec2 : i => instance.id }
  description = "Instance IDs of EC2 instances using maps"
}


