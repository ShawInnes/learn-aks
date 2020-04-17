resource "kubernetes_namespace" "certmanager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "certmanager" {
  name = "cert-manager"
  chart = "cert-manager"
  namespace = kubernetes_namespace.certmanager.metadata.0.name
  repository = data.helm_repository.jetstack.metadata.0.name
  version = "v0.14.2"
}

/// run a shell to do
// kubectl apply \
//    --namespace ratingsapp \
//    -f manifests/cluster-issuer.yaml
