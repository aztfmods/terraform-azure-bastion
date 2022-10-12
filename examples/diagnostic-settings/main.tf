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
      name     = "rg-${local.naming.company}-netw-${local.naming.env}-${local.naming.region}"
      location = "westeurope"
    }
  }
}

module "logging" {
  source = "github.com/aztfmods/module-azurerm-law"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  laws = {
    diags = {
      location      = module.global.groups.network.location
      resourcegroup = module.global.groups.network.name
      sku           = "PerGB2018"
      retention     = 30
    }
  }
  depends_on = [module.global]
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

      enable = {
        copy_paste = false
        file_copy  = false
        tunneling  = false
      }

      vnet = {
        name   = lookup(module.network.vnets.demo, "name", null)
        rgname = lookup(module.network.vnets.demo, "resource_group_name", null)
      }
    }
  }
  depends_on = [module.network]
}

module "diagnostic_settings" {
  source = "github.com/aztfmods/module-azurerm-diags"
  count  = length(module.bastion.merged_ids)

  resource_id           = element(module.bastion.merged_ids, count.index)
  logs_destinations_ids = [lookup(module.logging.laws.diags, "id", null)]
}