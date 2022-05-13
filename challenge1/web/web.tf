resource "azurerm_resource_group" "web-rg" {
  name     = "web-rg"
  location = "West Europe"
}

resource "azurerm_availability_set" "web-aset" {
  name                = "web-aset"
  location            = azurerm_resource_group.web-aset.location
  resource_group_name = azurerm_resource_group.web-aset.name

  tags = {
    environment = "Test"
  }
}

resource "azurerm_subnet" "web-sn" {
  name                 = "web-sn"
  resource_group_name  = azurerm_resource_group.web-rg.name
  virtual_network_name = data.terraform_remote_state.vnet.outputs.vnet-name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "web-nic" {
  name                = "web-nic"
  location            = azurerm_resource_group.web-rg.location
  resource_group_name = azurerm_resource_group.web-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web-sn.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "web-vm" {
  name                = "web-vm-01"
  resource_group_name = azurerm_resource_group.web-rg.name
  location            = azurerm_resource_group.web-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.web-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
