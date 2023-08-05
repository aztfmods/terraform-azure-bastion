provider "azurerm" {
  features {}
}

module "rg" {
  source = "github.com/aztfmods/terraform-azure-rg?ref=v0.1.0"

  environment = var.environment

  groups = {
    demo = {
      region = "westeurope"
    }
    network = {
      region = "westeurope"
    }
  }
}

module "network" {
  source = "github.com/aztfmods/terraform-azure-vnet?ref=v1.13.0"

  workload    = var.workload
  environment = var.environment

  vnet = {
    location      = module.rg.groups.network.location
    resourcegroup = module.rg.groups.network.name
    cidr          = ["10.18.0.0/16"]
  }
}

module "bastion" {
  source = "github.com/aztfmods/terraform-azure-bastion?ref=v1.4.0"

  workload    = var.workload
  environment = var.environment

  bastion = {
    location              = module.rg.groups.demo.location
    resourcegroup         = module.rg.groups.demo.name
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
}
