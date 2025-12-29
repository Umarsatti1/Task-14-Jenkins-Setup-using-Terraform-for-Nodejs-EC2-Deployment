variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "public_cidr" {
  type = string
}

variable "private_cidr" {
  type = string
}

variable "subnet_az" {
  type = string
}

variable "public_subnet_name" {
  type = string
}

variable "private_subnet_name" {
  type = string
}

variable "igw_name" {
  type = string
}

variable "eip_domain" {
  type = string
}

variable "eip_name" {
  type = string
}

variable "nat_name" {
  type = string
}

variable "public_rt" {
  type = string
}

variable "private_rt" {
  type = string
}

variable "public_route" {
  type = string
}

variable "fetch_ip" {
  type = string
}

variable "app_sg_name" {
  type = string
}

variable "jenkins_sg_name" {
  type = string
}