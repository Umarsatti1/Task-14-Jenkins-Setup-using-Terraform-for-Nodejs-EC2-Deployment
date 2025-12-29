# Input Variables
variable "ec2_app_name" {
  type = string
}

variable "ec2_jenkins_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_az" {
  type = string
}

variable "keypair" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "volume_type" {
  type = string
}

# Reference
variable "public_subnet" {
  type = string
}

variable "private_subnet" {
  type = string
}

variable "ec2_app_sg" {
  type = string
}

variable "ec2_jenkins_sg" {
  type = string
}

variable "instance_profile" {
  type = string
}