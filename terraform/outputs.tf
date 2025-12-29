output "app_ec2_ip" {
  value       = module.ec2.instance_ips["app-ec2"]
  description = "Application EC2 instance private IPv4 address"
}

output "jenkins_ec2_ip" {
  value       = module.ec2.instance_ips["jenkins-ec2"]
  description = "Jenkins Server EC2 instance private IPv4 address"
}

output "jenkins_ec2_instance_id" {
  value       = module.ec2.instance_ids["jenkins-ec2"]
  description = "Jenkins EC2 instance ID required for port forwarding"
}

