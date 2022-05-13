resource "azurerm_resource_group" "app-rg" {
  name     = "app-rg"
  location = "West Europe"
}

resource "azurerm_availability_set" "app-aset" {
  name                = "app-aset"
  location            = azurerm_resource_group.app-aset.location
  resource_group_name = azurerm_resource_group.app-aset.name

  tags = {
    environment = "Test"
  }
}

resource "azurerm_subnet" "app-sn" {
  name                 = "app-sn"
  resource_group_name  = azurerm_resource_group.app-rg.name
  virtual_network_name = data.terraform_remote_state.vnet.outputs.vnet-name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "app-nic" {
  name                = "app-nic"
  location            = azurerm_resource_group.app-rg.location
  resource_group_name = azurerm_resource_group.app-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app-sn.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app-vm" {
  name                = "app-vm-01"
  resource_group_name = azurerm_resource_group.app-rg.name
  location            = azurerm_resource_group.app-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.app-nic.id,
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
