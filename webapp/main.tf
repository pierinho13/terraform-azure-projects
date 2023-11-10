provider "azurerm" {
  features {}
  skip_provider_registration = true
  client_id       = var.arm_client_id
  client_secret   = var.arm_cliente_secret
  subscription_id = var.arm_suscription_id
  tenant_id       = var.arm_tenant_id
}


resource "azurerm_resource_group" "webapp" {
  name     = "webapp-resource-group"
  location = var.location_webapp
}

resource "azurerm_virtual_network" "vpc" {
  name                = "webapp-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.webapp.location
  resource_group_name = azurerm_resource_group.webapp.name
}

resource "azurerm_subnet" "example" {
  name                 = "webapp-subnet"
  resource_group_name  = azurerm_resource_group.webapp.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = ["10.0.1.0/24"]
}