variable "project" {
  description = "Project name"
  type        = string
  default     = "icons-for-md"
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
variable "exposed_app_port" {
  description = "Exposed app port"
  type = number
  default = 8402
}
variable "ssh_key_amazon_public" {
  description = "The path to your local public SSH key file for amazon."
  type        = string
  default     = "~/.ssh/id_amazon.pub"
}
variable "ssh_key_amazon_private" {
  description = "The path to your local private SSH key file for amazon."
  type        = string
  default     = "~/.ssh/id_amazon.pem"
}
variable "ssh_key_homelab_private" {
  description = "The path to your local private SSH key file for homelab."
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
  default     = "prod"
}