resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "helm_release" "nginx" {
  name = "nginx-ingress"
  chart = "nginx-ingress"
  namespace = kubernetes_namespace.ingress.metadata.0.name
  repository = data.helm_repository.stable.metadata.0.name
  set {
    name = "controller.replicaCount"
    value = 2
  }
  set {
    name = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }
  set {
    name = "defaultBackend.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }
}

data "kubernetes_service" "ingress" {
  metadata {
    namespace = kubernetes_namespace.ingress.metadata.0.name
    name = "${helm_release.nginx.name}-controller"
  }
}


locals {
  load_balancer_ingress_name = "frontend.${replace(data.kubernetes_service.ingress.load_balancer_ingress.0.ip, ".", "-")}.nip.io"
}

resource "kubernetes_ingress" "ratingsweb" {
  metadata {
    name = "ratings-web-ingress"
    namespace = kubernetes_namespace.aks.metadata.0.name

    annotations = {
      "kubernetes.io/ingress.class": "nginx"
      "cert-manager.io/cluster-issuer": "letsencrypt"
    }
  }
  spec {
    tls {
      hosts = [
        local.load_balancer_ingress_name]
      secret_name = "ratings-web-cert"
    }
    rule {
      host = local.load_balancer_ingress_name
      http {
        path {
          backend {
            service_name = kubernetes_service.ratings-web.metadata.0.name
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}
