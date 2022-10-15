provider "azurerm" {
  features {}
}

locals {
  naming = {
    company = "cn"
    env     = "p"
    region  = "weu"
  }
}

module "global" {
  source = "github.com/aztfmods/module-azurerm-global"
  rgs = {
    network = {
      name     = "rg-${local.naming.company}-bastion-${local.naming.env}-${local.naming.region}"
      location = "westeurope"
    }
  }
}

module "network" {
  source = "github.com/aztfmods/module-azurerm-vnet"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  vnets = {
    demo = {
      cidr          = ["10.19.0.0/16"]
      location      = module.global.groups.network.location
      resourcegroup = module.global.groups.network.name
    }
  }
  depends_on = [module.global]
}

module "bastion" {
  source = "../../"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  bastion = {
    demo = {
      location              = module.global.groups.network.location
      resourcegroup         = module.global.groups.network.name
      subnet_address_prefix = ["10.19.0.0/27"]
      scale_units           = 2

      enable = {
        copy_paste = false
        file_copy  = false
      }

      vnet = {
        name   = lookup(module.network.vnets.demo, "name", null)
        rgname = lookup(module.network.vnets.demo, "resource_group_name", null)
      }
    }
  }
  depends_on = [module.network]
}