resource "azurerm_resource_group" "ilb-rg" {
  name     = "LoadBalancerRG"
  location = "West Europe"
}

resource "azurerm_lb" "ilb" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.ilb-rg.location
  resource_group_name = azurerm_resource_group.ilb-rg.name

  frontend_ip_configuration {
    name                 = "PrivateIPAddress"
	subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend-ilb" {
  loadbalancer_id = azurerm_lb.ilb.id
  name            = "BackEndAddressPool"
}
