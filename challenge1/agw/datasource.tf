data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config = {
    storage_account_name = "terraform123abc"
    container_name       = "terraform-state"
    key                  = "vnet.terraform.tfstate"
  }
}