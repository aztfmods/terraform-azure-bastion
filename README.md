![example workflow](https://github.com/dkooll/terraform-azurerm-bastion/actions/workflows/validate.yml/badge.svg)

# Bastion Hosts

Terraform module which creates bastion hosts on Azure.

The below features are made available:

- Multiple bastion hosts
- Predefined network security group and rules
- Terratest is used to validate different integrations in [examples](examples)

The below examples shows the usage when consuming the module:

## Usage: single bastion host existing vnet

```hcl
module "network" {
  source = "github.com/dkooll/terraform-azurerm-vnet?ref=1.1.0"
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

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `bastion` | describes bastion related configuration | object | yes |
| `resourcegroup` | describes resourcegroup name | string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `subnets` | contains all subnets |
| `vnets` | contains all vnets |

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/dkooll/terraform-azurerm-bastion/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/dkooll/terraform-azurerm-bastion/tree/master/LICENSE) for full details.