resource "azurerm_resource_group" "vnet-rg" {
  name     = "vnet-rg-1"
  location = "West Europe"
}


resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  location            = azurerm_resource_group.web-sn.location
  resource_group_name = azurerm_resource_group.web-sn.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Test"
  }
}

output "vnet-name" {
  value = azurerm_virtual_network.vnet1.name
}