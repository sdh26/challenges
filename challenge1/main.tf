terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "vnet" {

 source  = "./vnet"
}

module "web" {
 source = "./web"
}

module "app" {
 source = "./app"
}

module "db" {
 source = "./db"
}
