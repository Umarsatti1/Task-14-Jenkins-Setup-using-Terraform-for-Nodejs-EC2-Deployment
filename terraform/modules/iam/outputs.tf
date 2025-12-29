output "instance_profile" {
  value       = aws_iam_instance_profile.instance_profile.name
  description = "Instance Profile name for App and Jenkins EC2s"
}