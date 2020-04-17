resource "random_pet" "analytics" {
}

locals {
  log_analytics_workspace = "aksworkshop-workspace-${random_pet.analytics.id}"
}

resource "azurerm_log_analytics_workspace" "aks" {
  name = local.log_analytics_workspace
  location = azurerm_kubernetes_cluster.aks.location
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
  sku = "Free"
}
