# Common Resources

data "kubectl_filename_list" "api_gw_manifests" {
  pattern = "${path.module}/api-gw/*.yaml"
}

# Production Resources

# Create Consul namespace
resource "kubernetes_namespace" "consul-prod" {
  provider = kubernetes.production
  metadata {
    name = "consul"
  }
}

# Create Kubernetes secrets for Consul components
resource "kubernetes_secret" "consul_bootstrap_token-prod" {
  provider = kubernetes.production
  metadata {
    name      = "bootstrap-token"
    namespace = "consul"
  }

  data = {
    token = hcp_consul_cluster_root_token.token.secret_id
  }

  depends_on = [
    module.eks-prod.eks_managed_node_groups,
    kubernetes_namespace.consul-prod
  ]
}

# Install Consul components on EKS
resource "helm_release" "consul-prod" {
  provider         = helm.production
  name             = "consul"
  repository       = "https://helm.releases.hashicorp.com"
  version          = var.consul_chart_version
  chart            = "consul"
  namespace        = "consul"
  create_namespace = true
  wait             = false

  values = [
    templatefile("${path.module}/helm/${var.consul_helm_filename}", {
      datacenter = hcp_consul_cluster.main.datacenter
      # strip out url scheme from the public url
      consul_hosts       = substr(hcp_consul_cluster.main.consul_public_endpoint_url, 8, -1)
      k8s_api_endpoint   = data.aws_eks_cluster.cluster-prod.endpoint
      consul_version     = var.consul_version
      boostrap_acl_token = hcp_consul_cluster_root_token.token.secret_id
      partition          = "production"
    })
  ]

  depends_on = [
    module.eks-prod.eks_managed_node_groups,
    module.eks-prod.aws_eks_addon,
    kubernetes_namespace.consul-prod,
    hcp_consul_cluster_root_token.token,
    hcp_consul_cluster.main,
    kubernetes_secret.consul_bootstrap_token-prod,
    module.vpc
  ]
}

## Create API Gateway
resource "kubectl_manifest" "api_gw-prod" {
  provider  = kubectl.production
  count     = length(data.kubectl_filename_list.api_gw_manifests.matches)
  yaml_body = file(element(data.kubectl_filename_list.api_gw_manifests.matches, count.index))

  depends_on = [helm_release.consul-prod]
}

# locals {
#   # non-default context name to protect from using wrong kubeconfig
#   kubeconfig_context = "_terraform-kubectl-context-${local.name}_"

#   kubeconfig = {
#     apiVersion = "v1"
#     clusters = [
#       {
#         name = local.kubeconfig_context
#         cluster = {
#           certificate-authority-data = data.aws_eks_cluster.cluster.certificate_authority.0.data
#           server                     = data.aws_eks_cluster.cluster.endpoint
#         }
#       }
#     ]
#     users = [
#       {
#         name = local.kubeconfig_context
#         user = {
#           token = data.aws_eks_cluster_auth.cluster.token
#         }
#       }
#     ]
#     contexts = [
#       {
#         name = local.kubeconfig_context
#         context = {
#           cluster   = local.kubeconfig_context
#           user      = local.kubeconfig_context
#           namespace = "consul"
#         }
#       }
#     ]
#   }
#}

# Development Resources

# Create Consul namespace
resource "kubernetes_namespace" "consul-dev" {
  provider = kubernetes.development
  metadata {
    name = "consul"
  }
}

# Create Kubernetes secrets for Consul components
resource "kubernetes_secret" "consul_bootstrap_token-dev" {
  provider = kubernetes.development
  metadata {
    name      = "bootstrap-token"
    namespace = "consul"
  }

  data = {
    token = hcp_consul_cluster_root_token.token.secret_id
  }

  depends_on = [
    module.eks-dev.eks_managed_node_groups,
    kubernetes_namespace.consul-dev
  ]
}

# Install Consul components on EKS
resource "helm_release" "consul-dev" {
  provider         = helm.development
  name             = "consul"
  repository       = "https://helm.releases.hashicorp.com"
  version          = var.consul_chart_version
  chart            = "consul"
  namespace        = "consul"
  create_namespace = true
  wait             = false

  values = [
    templatefile("${path.module}/helm/${var.consul_helm_filename}", {
      datacenter = hcp_consul_cluster.main.datacenter
      # strip out url scheme from the public url
      consul_hosts       = substr(hcp_consul_cluster.main.consul_public_endpoint_url, 8, -1)
      k8s_api_endpoint   = data.aws_eks_cluster.cluster-dev.endpoint
      consul_version     = var.consul_version
      boostrap_acl_token = hcp_consul_cluster_root_token.token.secret_id
      partition          = "development"
    })
  ]

  depends_on = [
    module.eks-dev.eks_managed_node_groups,
    module.eks-dev.aws_eks_addon,
    kubernetes_namespace.consul-dev,
    hcp_consul_cluster_root_token.token,
    hcp_consul_cluster.main,
    kubernetes_secret.consul_bootstrap_token-dev,
    module.vpc
  ]
}

## Create API Gateway
resource "kubectl_manifest" "api_gw-dev" {
  provider  = kubectl.development
  count     = length(data.kubectl_filename_list.api_gw_manifests.matches)
  yaml_body = file(element(data.kubectl_filename_list.api_gw_manifests.matches, count.index))

  depends_on = [helm_release.consul-dev]
}
