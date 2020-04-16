
resource "azurerm_resource_group" "aks" {
  name = var.RESOURCE_GROUP
  location = var.REGION_NAME

  tags = {
    environment = "Learn"
  }
}
