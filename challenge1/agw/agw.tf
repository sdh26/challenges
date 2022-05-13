resource "azurerm_resource_group" "agw-rg" {
  name     = "agw-rg"
  location = "West Europe"
}


resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.agw-rg.name
  virtual_network_name = data.terraform_remote_state.vnet.outputs.vnet-name
  address_prefixes     = ["10.254.0.0/24"]
}


resource "azurerm_public_ip" "pip" {
  name                = "agw-pip"
  resource_group_name = azurerm_resource_group.agw-rg.name
  location            = azurerm_resource_group.agw-rg.location
  allocation_method   = "Static"
}


resource "azurerm_application_gateway" "network" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.agw-rg.name
  location            = azurerm_resource_group.agw-rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend_ip_configuration_name"
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = "backend_address_pool_name"
  }

  backend_http_settings {
    name                  = "http_setting_name"
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listener_name"
    frontend_ip_configuration_name = "frontend_ip_configuration_name"
    frontend_port_name             = "frontend_port_name"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "request_routing_rule_name"
    rule_type                  = "Basic"
    http_listener_name         = "listener_name"
    backend_address_pool_name  = "backend_address_pool_name"
    backend_http_settings_name = "http_setting_name"
  }
}