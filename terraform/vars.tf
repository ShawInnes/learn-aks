variable "REGION_NAME" {
  type = string
  default = "australiaeast"
}

variable "RESOURCE_GROUP" {
  type = string
  default = "aksworkshop"
}

variable "SUBNET_NAME" {
  type = string
  default = "aks-subnet"
}

variable "VNET_NAME" {
  type = string
  default = "aks-vnet"
}

variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
  default = 3
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "k8stest"
}
