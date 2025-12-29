locals {
  public-subnet = {
    cidr = var.public_cidr
    az   = var.subnet_az
  }
  private-subnet = {
    cidr = var.private_cidr
    az   = var.subnet_az
  }
  my_ip_cidr = "${data.http.my_ip.response_body}/32"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public-subnet.cidr
  availability_zone       = local.public-subnet.az
  map_public_ip_on_launch = true

  tags = {
    Name = "uts-${var.public_subnet_name}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private-subnet.cidr
  availability_zone = local.private-subnet.az

  tags = {
    Name = "uts-${var.private_subnet_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_eip" "nat_eip" {
  domain = var.eip_domain

  tags = {
    Name = var.eip_name
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = var.nat_name
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.public_route
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_rt
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.public_route
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.private_rt
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# Fetch My IP - Data source
data "http" "my_ip" {
  url = var.fetch_ip
}

# Application EC2 Security group
resource "aws_security_group" "ec2_app_sg" {
  name        = var.app_sg_name
  description = "Inbound traffic on port 22, 80, and 3000."
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.public_route]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.public_route]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_jenkins_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_route]
  }

  tags = {
    Name = var.app_sg_name
  }
}

# Jenkins Server EC2 Security group
resource "aws_security_group" "ec2_jenkins_sg" {
  name        = var.jenkins_sg_name
  description = "Allows port 22 (SSH) and port 8080 traffic from My IP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_route]
  }

  tags = {
    Name = var.jenkins_sg_name
  }
}