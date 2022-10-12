![example workflow](https://github.com/aztfmods/module-azurerm-vnet/actions/workflows/validate.yml/badge.svg)

# Bastion Hosts

Terraform module which creates bastion hosts on Azure.

The below features are made available:

- multiple bastion hosts
- predefined network security group and rules
- terratest is used to validate different integrations in [examples](examples)
- [diagnostic](examples/diagnostic-settings/main.tf) logs integration

The below examples shows the usage when consuming the module:

## Usage: single bastion host existing vnet

```hcl
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
```

## Resources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_bastion_host](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_subnet_network_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |

## Data Sources

| Name | Type |
| :-- | :-- |
| [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | datasource |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/1.39.0/docs/data-sources/resource_group) | datasource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `bastion` | describes bastion related configuration | object | yes |
| `naming` | contains naming convention | string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `bastion_hosts` | contains all bastion hosts |
| `merged_ids` | contains all resource id's specified within the object |

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/dkooll/terraform-azurerm-bastion/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/dkooll/terraform-azurerm-bastion/tree/master/LICENSE) for full details.