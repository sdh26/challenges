resource "azurerm_resource_group" "db-rg" {
  name     = "db-rg"
  location = "West Europe"
}

resource "azurerm_availability_set" "db-aset" {
  name                = "db-aset"
  location            = azurerm_resource_group.db-aset.location
  resource_group_name = azurerm_resource_group.db-aset.name

  tags = {
    environment = "Test"
  }
}

resource "azurerm_subnet" "db-sn" {
  name                 = "db-sn"
  resource_group_name  = azurerm_resource_group.db-rg.name
  virtual_network_name = data.terraform_remote_state.vnet.outputs.vnet-name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "db-nic" {
  name                = "db-nic"
  location            = azurerm_resource_group.db-rg.location
  resource_group_name = azurerm_resource_group.db-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.db-sn.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "db-vm" {
  name                = "db-vm-01"
  resource_group_name = azurerm_resource_group.db-rg.name
  location            = azurerm_resource_group.db-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.db-nic.id,
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
