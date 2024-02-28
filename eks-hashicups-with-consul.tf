data "kubectl_path_documents" "docs" {
  pattern = "${path.module}/hashicups/*.yaml"
}

resource "kubectl_manifest" "hashicups" {
  for_each  = toset(data.kubectl_path_documents.docs.documents)
  yaml_body = each.value

  depends_on = [
    helm_release.consul,
    helm_release.grafana,
    kubernetes_namespace.backend,
    kubernetes_namespace.frontend,
  ]
}

resource "kubernetes_namespace" "frontend" {
  metadata {
    name = "frontend"
  }
}

resource "kubernetes_namespace" "backend" {
  metadata {
    name = "backend"
  }
}
