# output "aws_ami" {
#   value = data.aws_ami.amazon-linux
# }

output "ec2_instance_ip" {
  value = module.ec2_instance.*.public_ip
}