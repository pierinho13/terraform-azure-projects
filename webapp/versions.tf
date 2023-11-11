terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.50.0"
    }
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "webapp-resource-group"
    storage_account_name = "terraformstatepierinho18"
    container_name       = "webappfirst"
    key                  = "terraform.tfstate"
  }
}