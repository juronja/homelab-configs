variable "project" {
  description = "Project name"
  type        = string
  default     = "prometheus"
}
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
variable "vpc_cidr_block" {
  description = "VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}
variable "private_cidr_blocks" {
  description = "Private cidr blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "public_cidr_blocks" {
  description = "Public cidr blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "instance_type" {
  description = "Instance type"
  default     = ["t2.micro"]
}
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}