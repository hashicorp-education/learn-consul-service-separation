################################################################################
# VPC
################################################################################

output "region" {
  value = var.vpc_region
}


################################################################################
# HCP Consul
################################################################################

output "consul_root_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}

output "consul_url" {
  value = hcp_consul_cluster.main.public_endpoint ? (
    hcp_consul_cluster.main.consul_public_endpoint_url
    ) : (
    hcp_consul_cluster.main.consul_private_endpoint_url
  )
}

################################################################################
# Prod EKS Cluster
################################################################################

output "prod_cluster_endpoint" {
  value = data.aws_eks_cluster.cluster-prod.endpoint
}

output "prod_cluster_name" {
  value = module.eks-prod.cluster_name
}

################################################################################
# Dev EKS Cluster
################################################################################

output "dev_cluster_endpoint" {
  value = data.aws_eks_cluster.cluster-dev.endpoint
}

output "dev_cluster_name" {
  value = module.eks-dev.cluster_name
}

output "kubectl_setup" {
  value = <<EOT
  # run the following to set up two contexts for kubectl - `dev` and `prod`
  aws eks --region ${var.vpc_region} update-kubeconfig --name ${module.eks-dev.cluster_name} --alias dev
  aws eks --region ${var.vpc_region} update-kubeconfig --name ${module.eks-prod.cluster_name} --alias prod
  EOT
}