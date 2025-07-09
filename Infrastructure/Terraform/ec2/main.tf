terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

#######################
## VPC configuration ##
#######################

data "aws_availability_zones" "azs" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr_block

  azs             = [data.aws_availability_zones.azs.names[0]]
  public_subnets  = var.public_cidr_block

  enable_dns_hostnames = true # Will add public dns hostnames
  enable_dns_support = true

  tags = {
    Name = "${var.project}-${var.environment}-vpc"
    Environment = var.environment
  }
}

############################
## Firewall configuration ##
############################

resource "aws_security_group" "security-group" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.project}-${var.environment}-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
  security_group_id = aws_security_group.security-group.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow-utm-builder" {
  security_group_id = aws_security_group.security-group.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port =7474
  to_port = 7474
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow-all" {
  security_group_id = aws_security_group.security-group.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1" # semantically equivalent to all ports
}

# #######################
# ## EC2 configuration ##
# #######################

# Generate a key in AWS from your local pub key
resource "aws_key_pair" "ssh_key_amazon" {
  key_name = "id_amazon_terraform"
  public_key = file(var.ssh_key_amazon)
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"

  name = "${var.project}-instance-${count.index + 1}"
  
  ami                    = data.aws_ami.amazon-linux.id
  instance_type          = var.instance_type
  count                  = 3
  key_name               = aws_key_pair.ssh_key_amazon.key_name
  vpc_security_group_ids = [aws_security_group.security-group.id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true

  # user_data = file("ec2-bootstrap-commands.sh")

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}



