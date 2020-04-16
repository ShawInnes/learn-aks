output "client_key" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.password
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "resource_group" {
  value = azurerm_resource_group.aks.name
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "acr_name" {
  value = azurerm_container_registry.aks.name
}

output "mongodb_database" {
  value = var.mongodb_database
}

output "mongodb_user" {
  value = var.mongodb_username
}

output "mongodb_password" {
  value = random_password.mongouser.result
}

output "MONGOCONNECTION" {
  value = local.MONGOCONNECTION
}
