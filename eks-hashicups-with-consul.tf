data "kubectl_path_documents" "docs" {
  pattern = "${path.module}/hashicups/*.yaml"
}

# Production Resources
resource "kubectl_manifest" "hashicups-prod" {
  provider = kubectl.production
  for_each  = toset(data.kubectl_path_documents.docs.documents)
  yaml_body = each.value

  depends_on = [
    helm_release.consul-prod,
    kubernetes_namespace.backend-prod,
    kubernetes_namespace.frontend-prod,
  ]
}

resource "kubernetes_namespace" "frontend-prod" {
  provider = kubernetes.production

  metadata {
    name = "frontend"
  }
}

resource "kubernetes_namespace" "backend-prod" {
  provider = kubernetes.production

  metadata {
    name = "backend"
  }
}

# Development Resources
resource "kubectl_manifest" "hashicups-dev" {
  provider = kubectl.development
  for_each  = toset(data.kubectl_path_documents.docs.documents)
  yaml_body = each.value

  depends_on = [
    helm_release.consul-dev,
    kubernetes_namespace.backend-dev,
    kubernetes_namespace.frontend-dev,
  ]
}

resource "kubernetes_namespace" "frontend-dev" {
  provider = kubernetes.development

  metadata {
    name = "frontend"
  }
}

resource "kubernetes_namespace" "backend-dev" {
  provider = kubernetes.development
  
  metadata {
    name = "backend"
  }
}
