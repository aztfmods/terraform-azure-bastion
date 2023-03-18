provider "azurerm" {
  features {}
}

module "global" {
  source = "github.com/aztfmods/module-azurerm-global"

  company = "cn"
  env     = "p"
  region  = "weu"

  rgs = {
    demo    = {location = "westeurope" }
    network = { location = "westeurope" }
  }
}

module "network" {
  source = "github.com/aztfmods/module-azurerm-vnet"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  vnet = {
    location      = module.global.groups.network.location
    resourcegroup = module.global.groups.network.name
    cidr          = ["10.18.0.0/16"]
  }
  depends_on = [module.global]
}

module "bastion" {
  source = "../../"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  bastion = {
    location              = module.global.groups.demo.location
    resourcegroup         = module.global.groups.demo.name
    subnet_address_prefix = ["10.18.0.0/27"]
    scale_units           = 2
    sku                   = "Standard"

    enable = {
      copy_paste = false
      file_copy  = false
      ip_connect = true
    }

    vnet = {
      name   = module.network.vnet.name
      rgname = module.network.vnet.resource_group_name
    }
  }
  depends_on = [module.network]
}