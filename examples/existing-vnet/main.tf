provider "azurerm" {
  features {}
}

module "network" {
  source = "github.com/aztfmods/module-azurerm-vnet"
  vnets = {
    bastion = {
      cidr          = ["10.19.0.0/16"]
      location      = "eastus2"
      resourcegroup = "rg-network-eus2"
    }
  }
}

module "bastion" {
  source     = "../../"
  depends_on = [module.network]
  bastion = {
    host1 = {
      resourcegroup         = "rg-bastion-dev"
      location              = "eastus2"
      subnet_address_prefix = ["10.19.0.0/27"]
      enable_copy_paste     = false
      enable_file_copy      = false
      enable_tunneling      = false
      existing = {
        vnetname = lookup(module.network.vnets.bastion, "name", null)
        rgname   = lookup(module.network.vnets.bastion, "resource_group_name", null)
      }
    }
  }
}