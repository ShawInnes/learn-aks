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

  agent_pool_profile {
  }
}

resource "azurerm_container_registry" "aks" {
  name = local.ACR_NAME
  location = var.REGION_NAME
  resource_group_name = azurerm_resource_group.aks.name
  sku = "Standard"
}

