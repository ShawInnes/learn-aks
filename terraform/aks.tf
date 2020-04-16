
resource "azurerm_resource_group" "aks" {
  name = var.RESOURCE_GROUP
  location = var.REGION_NAME
  tags = {
    environment = "Learn"
  }
}

resource "azurerm_virtual_network" "aks" {
  name = var.VNET_NAME
  resource_group_name = var.RESOURCE_GROUP
  address_space = ["10.0.0.0/8"]
  location = var.REGION_NAME
  subnet {
    address_prefix = "10.240.0.0/16"
    name = var.SUBNET_NAME
  }
}

