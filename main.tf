resource "kubernetes_namespace" "main" {
  metadata {
    name = "main"
  }
}
