terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.83.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.20.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.26.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2"
    }
  }

  provider_meta "hcp" {
    module_name = "hcp-consul"
  }
}

provider "aws" {
  region = var.vpc_region
}

provider "consul" {
  address    = hcp_consul_cluster.main.consul_public_endpoint_url
  datacenter = hcp_consul_cluster.main.datacenter
  token      = hcp_consul_cluster_root_token.token.secret_id
}

provider "helm" {
  alias = "production"

  kubernetes {
    host                   = data.aws_eks_cluster.cluster-prod.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster-prod.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster-prod.token
  }
}

provider "kubernetes" {
  alias                  = "production"
  host                   = data.aws_eks_cluster.cluster-prod.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster-prod.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster-prod.token
}

provider "kubectl" {
  alias                  = "production"
  host                   = data.aws_eks_cluster.cluster-prod.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster-prod.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster-prod.token
  load_config_file       = false
}

provider "helm" {
  alias = "development"

  kubernetes {
    host                   = data.aws_eks_cluster.cluster-dev.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster-dev.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster-dev.token
  }
}

provider "kubernetes" {
  alias                  = "development"
  host                   = data.aws_eks_cluster.cluster-dev.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster-dev.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster-dev.token
}

provider "kubectl" {
  alias                  = "development"
  host                   = data.aws_eks_cluster.cluster-dev.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster-dev.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster-dev.token
  load_config_file       = false
}
