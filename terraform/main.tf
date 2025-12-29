module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  vpc_name            = var.vpc_name
  public_cidr         = var.public_cidr
  private_cidr        = var.private_cidr
  subnet_az           = var.subnet_az
  public_subnet_name  = var.public_subnet_name
  private_subnet_name = var.private_subnet_name
  igw_name            = var.igw_name
  eip_domain          = var.eip_domain
  eip_name            = var.eip_name
  nat_name            = var.nat_name
  public_rt           = var.public_rt
  private_rt          = var.private_rt
  public_route        = var.public_route
  fetch_ip            = var.fetch_ip
  app_sg_name         = var.app_sg_name
  jenkins_sg_name     = var.jenkins_sg_name
}

module "iam" {
  source           = "./modules/iam"
  ec2_role         = var.ec2_role
  ec2_policy       = var.ec2_policy
  instance_profile = var.instance_profile
}

module "ec2" {
  source           = "./modules/ec2"
  ec2_app_name     = var.ec2_app_name
  ec2_jenkins_name = var.ec2_jenkins_name
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  instance_az      = var.instance_az
  keypair          = var.keypair
  volume_size      = var.volume_size
  volume_type      = var.volume_type
  public_subnet    = module.vpc.public_subnet
  private_subnet   = module.vpc.private_subnet
  ec2_app_sg       = module.vpc.ec2_app_sg_id
  ec2_jenkins_sg   = module.vpc.ec2_jenkins_sg_id
  instance_profile = module.iam.instance_profile
}