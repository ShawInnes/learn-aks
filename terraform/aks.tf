resource "azurerm_resource_group" "aks" {
  name = var.RESOURCE_GROUP
  location = var.REGION_NAME
  tags = {
    environment = "Learn"
  }
}

resource "azurerm_virtual_network" "aks" {
  name = var.VNET_NAME
  resource_group_name = azurerm_resource_group.aks.name
  address_space = [
    "10.0.0.0/8"]
  location = var.REGION_NAME
  subnet {
    address_prefix = "10.240.0.0/16"
    name = var.SUBNET_NAME
  }
}

resource "random_pet" "cluster" {
}

resource "random_string" "registry" {
  length = 16
  special = false
  upper = false
}

locals {
  AKS_CLUSTER_NAME = "aksworkshop-${random_pet.cluster.id}"
  ACR_NAME = "acr${random_string.registry.result}"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name = local.AKS_CLUSTER_NAME
  location = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix = var.dns_prefix

  kubernetes_version = "1.16.7"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name = "agentpool"
    node_count = var.agent_count
    vm_size = "Standard_DS1_v2"
  }

  service_principal {
    client_id = var.client_id
    client_secret = var.client_secret
  }
}

resource "kubernetes_namespace" "aks" {
  metadata {
    name = var.namespace
  }
}

resource "azurerm_container_registry" "aks" {
  name = local.ACR_NAME
  location = var.REGION_NAME
  resource_group_name = azurerm_resource_group.aks.name
  sku = "Standard"
}

data "helm_repository" "bitnami" {
  name = "bitnami"
  url = "https://charts.bitnami.com/bitnami"
}

resource "random_password" "mongouser" {
  length = 16
  special = false
}

resource "helm_release" "mongo" {
  name = "ratings"
  chart = "mongodb"
  namespace = kubernetes_namespace.aks.metadata.0.name
  repository = data.helm_repository.bitnami.metadata.0.name
  set {
    name = "mongodbUsername"
    value = var.mongodb_username
  }
  set {
    name = "mongodbPassword"
    value = random_password.mongouser.result
  }
  set {
    name = "mongodbDatabase"
    value = var.mongodb_database
  }
}

locals {
  api_container_name = "ratings-api"
  web_container_name = "ratings-web"
  MONGOCONNECTION = "mongodb://${var.mongodb_username}:${random_password.mongouser.result}@${helm_release.mongo.name}-mongodb.${var.namespace}.svc.cluster.local:27017/${var.mongodb_database}"
}

resource "kubernetes_secret" "mongosecret" {
  metadata {
    name = "mongosecret"
    namespace = kubernetes_namespace.aks.metadata.0.name
  }

  data = {
    MONGOCONNECTION = local.MONGOCONNECTION
  }
}

resource "kubernetes_deployment" "ratings-api" {
  metadata {
    name = local.api_container_name
    namespace = kubernetes_namespace.aks.metadata.0.name
    labels = {
      app = local.api_container_name
    }
  }
  spec {
    selector {
      match_labels = {
        app = local.api_container_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.api_container_name
        }
      }
      spec {
        container {
          name = local.api_container_name
          image = "${azurerm_container_registry.aks.login_server}/${local.api_container_name}:v1"
          image_pull_policy = "Always"
          port {
            container_port = 3000
          }
          env {
            name = "MONGODB_URI"
            value_from {
              secret_key_ref {
                name = "mongosecret"
                key = "MONGOCONNECTION"
              }
            }
          }
          resources {
            requests {
              cpu = "250m"
              memory = "64Mi"
            }
            limits {
              cpu = "500m"
              memory = "256Mi"
            }
          }
          readiness_probe {
            http_get {
              port = "3000"
              path = "/healthz"
            }
          }
          liveness_probe {
            http_get {
              port = "3000"
              path = "/healthz"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ratings-api" {
  metadata {
    name = local.api_container_name
    namespace = kubernetes_namespace.aks.metadata.0.name
  }
  spec {
    selector = {
      app = local.api_container_name
    }
    port {
      port = 80
      protocol = "TCP"
      target_port = "3000"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "ratings-web" {
  metadata {
    name = local.web_container_name
    namespace = kubernetes_namespace.aks.metadata.0.name
    labels = {
      app = local.web_container_name
    }
  }
  spec {
    selector {
      match_labels = {
        app = local.web_container_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.web_container_name
        }
      }
      spec {
        container {
          name = local.web_container_name
          image = "${azurerm_container_registry.aks.login_server}/${local.web_container_name}:v1"
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
          env {
            name = "API"
            value = "http://${local.api_container_name}.${kubernetes_namespace.aks.metadata.0.name}.svc.cluster.local"
          }
          resources {
            requests {
              cpu = "250m"
              memory = "64Mi"
            }
            limits {
              cpu = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "ratings-web" {
  metadata {
    name = local.web_container_name
    namespace = kubernetes_namespace.aks.metadata.0.name
  }
  spec {
    selector = {
      app = local.web_container_name
    }
    port {
      port = 80
      protocol = "TCP"
      target_port = "8080"
    }
    type = "LoadBalancer"
  }
}

