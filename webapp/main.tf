provider "azurerm" {
  features {}
  skip_provider_registration = true
  client_id                  = var.arm_client_id
  client_secret              = var.arm_cliente_secret
  subscription_id            = var.arm_suscription_id
  tenant_id                  = var.arm_tenant_id
}

data "azurerm_image" "nginx" {
  name                = "nginx-as-simple-as-possible"
  resource_group_name = "cloud-shell-storage-westeurope"
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

resource "azurerm_subnet" "subnet" {
  name                 = "webapp-subnet"
  resource_group_name  = azurerm_resource_group.webapp.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "webapp_ip" {
  name                = "webapp-first"
  location            = azurerm_resource_group.webapp.location
  resource_group_name = azurerm_resource_group.webapp.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "webapp_interface" {
  name                = "webapp-interface-nic"
  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_resource_group.webapp.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webapp_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "webappp_instance" {
  name                            = "webapp-vm"
  resource_group_name             = azurerm_resource_group.webapp.name
  location                        = var.location_webapp
  size                            = "Standard_D2s_v3"
  admin_username                  = "adminuser"
  admin_password                  = var.password_instance
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.webapp_interface.id,
  ]

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

  #source image: https://github.com/pierinho13/packer-azure-simpliest/tree/main
  source_image_id = data.azurerm_image.nginx.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
