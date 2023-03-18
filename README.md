# Bastion Host

This Terraform module simplifies the creation of a secure bastion host for remote access to private instances within a network, with configurable options for security groups, instance type, and key pair authentication.

The below features are made available:

- predefined network security group and rules
- existing virtual network usage
- terratest is used to validate different integrations

The below examples shows the usage when consuming the module:

## Usage: simple

```hcl
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
| `company` | contains the company name used, for naming convention | string | yes |
| `region` | contains the shortname of the region, used for naming convention | string | yes |
| `env` | contains shortname of the environment used for naming convention | string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `bastion` | contains all bastion related configuration |

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/aztfmods/module-azurerm-bastion/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/aztfmods/module-azurerm-bastion/blob/main/LICENSE) for full details.