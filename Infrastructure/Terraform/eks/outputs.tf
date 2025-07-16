output "cluster_name" {
  value = module.eks.cluster_name
}
output "kubeconfig" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}