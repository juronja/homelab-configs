terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
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

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_cidr_blocks
  public_subnets  = var.public_cidr_blocks

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    Environment = var.environment
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}


###############################
## EKS Cluster configuration ##
###############################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name    = "${var.project}-cluster"
  cluster_version = "1.33"

  # VPC
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  bootstrap_self_managed_addons = true

  # Access
  authentication_mode = "API"
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = [ "0.0.0.0/0" ] # Limit to your IP if needed

  # # AWS Load Balancer Controller
  # enable_irsa = true
  # cluster_addons = {
  #   aws-load-balancer-controller = {
  #     most_recent = true # Use the latest version of the add-on
  #   }
  # }  

  # Node group
  eks_managed_node_groups = {
    nodegroup1 = {
      name           = "${var.project}-node-group"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.instance_type
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  # Override defaults
  create_cloudwatch_log_group = false
  # create_kms_key = false

  tags = {
    Environment = var.environment
  }
}

#####################################
## ALB Load Balancer configuration ##
#####################################

# NOTE: The AWS Load Balancer Controller will automatically create and manage
# Target Groups and Listener Rules for you based on Kubernetes Ingress objects.
#
# You are defining the main ALB resource here. The controller will then add rules to it.

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "9.17.0"

#   name = "${var.project}-alb-${var.environment}"
#   load_balancer_type = "application"
#   vpc_id = module.vpc.vpc_id
#   subnets = module.vpc.public_subnets

#   # Listeners for the ALB
#   listeners = {
#     # This listener will forward traffic to target groups created by the controller
#     http = {
#       port     = 80
#       protocol = "HTTP"
#       # A default action is required. The controller will add rules to override this.
#       default_action = {
#         type = "fixed-response"
#         fixed_response = {
#           content_type = "text/plain"
#           message_body = "Cannot route request"
#           status_code  = "404"
#         }
#       }
#     }
#   }

#   tags = {
#     Environment = var.environment
#   }
# }


