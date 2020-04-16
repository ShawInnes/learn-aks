provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.5.0"

  features {
  }
}

provider "helm" {
  version = "~> 1.1"
}

provider "random" {
  version = "~> 2.2"
}

provider "kubernetes" {
  version = "~> 1.11"
}
