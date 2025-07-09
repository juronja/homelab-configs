variable "project" {
  description = "Project name"
  type        = string
  default     = "test"
}
variable "vpc_cidr_block" {
  description = "VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_cidr_block" {
  description = "Public cidr blocks"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
variable "ssh_key_amazon" {
  description = "The path to your local public SSH key file for amazon."
  type        = string
  default     = "~/.ssh/id_amazon.pub"
}
variable "ssh_key_homelab" {
  description = "The path to your local public SSH key file for homelab."
  type        = string
  default     = "~/.ssh/id_ubuntu-homelab"
}
variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}