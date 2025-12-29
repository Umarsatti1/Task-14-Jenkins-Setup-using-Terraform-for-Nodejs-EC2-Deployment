# VPC Vars
vpc_cidr            = "10.0.0.0/16"
vpc_name            = "umarsatti-vpc"
public_cidr         = "10.0.1.0/24"
private_cidr        = "10.0.2.0/24"
subnet_az           = "us-west-1a"
public_subnet_name  = "public-subnet"
private_subnet_name = "private-subnet"
igw_name            = "umarsatti-igw"
eip_domain          = "vpc"
eip_name            = "umarsatti-nat-eip"
nat_name            = "umarsatti-nat-gw"
public_rt           = "umarsatti-public-rt"
private_rt          = "umarsatti-private-rt"
public_route        = "0.0.0.0/0"
fetch_ip            = "https://api.ipify.org"
app_sg_name         = "public-sg"
jenkins_sg_name     = "jenkins-sg"

# IAM Vars
ec2_role         = "ec2-instance-role-nodejs-jenkins"
ec2_policy       = "ec2-instance-policy-nodejs-jenkins"
instance_profile = "instance-profile-nodejs-jenkins"

# EC2 Vars
ec2_app_name     = "nodejs-app-instance"
ec2_jenkins_name = "jenkins-nodejs-server"
ami_id           = "ami-0e6a50b0059fd2cc3"
instance_type    = "t3.small"
instance_az      = "us-west-1a"
keypair          = "uts"
volume_size      = 10
volume_type      = "gp3"





