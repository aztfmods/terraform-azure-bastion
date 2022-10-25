#----------------------------------------------------------------------------------------
# resourcegroups
#----------------------------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  for_each = var.bastion

  name = each.value.resourcegroup
}

#----------------------------------------------------------------------------------------
# existing vnets
#----------------------------------------------------------------------------------------

data "azurerm_virtual_network" "vnet" {
  for_each = var.bastion

  name                = each.value.vnet.name
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
}

#----------------------------------------------------------------------------------------
# subnets
#----------------------------------------------------------------------------------------

resource "azurerm_subnet" "sn" {
  for_each = var.bastion

  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.rg[each.key].name
  virtual_network_name = data.azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = each.value.subnet_address_prefix
}

#----------------------------------------------------------------------------------------
# public ip's
#----------------------------------------------------------------------------------------

resource "azurerm_public_ip" "pip" {
  for_each = var.bastion

  name                = "pip-${var.naming.company}-${each.key}-${var.naming.env}-${var.naming.region}"
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  location            = data.azurerm_resource_group.rg[each.key].location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

#----------------------------------------------------------------------------------------
# bastion hosts
#----------------------------------------------------------------------------------------

resource "azurerm_bastion_host" "bastion" {
  for_each = var.bastion

  name                = "bas-${var.naming.company}-${each.key}-${var.naming.env}-${var.naming.region}"
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  location            = data.azurerm_resource_group.rg[each.key].location

  sku                    = try(each.value.sku, "Basic")
  scale_units            = try(each.value.scale_units, 2)
  copy_paste_enabled     = try(each.value.enable.copy_paste, false)
  file_copy_enabled      = try(each.value.enable.file_copy, false) && each.value.sku != "Basic"
  tunneling_enabled      = try(each.value.enable.tunneling, false) && each.value.sku != "Basic"
  ip_connect_enabled     = try(each.value.enable.ip_connect, false) && each.value.sku != "Basic"
  shareable_link_enabled = try(each.value.enable.shareable_link, false) && each.value.sku != "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.sn[each.key].id
    public_ip_address_id = azurerm_public_ip.pip[each.key].id
  }
}

#----------------------------------------------------------------------------------------
# nsg's
#----------------------------------------------------------------------------------------

resource "azurerm_network_security_group" "nsg" {
  for_each = var.bastion

  name                = "nsg-${var.naming.company}-${each.key}-${var.naming.env}-${var.naming.region}"
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  location            = data.azurerm_resource_group.rg[each.key].location

  dynamic "security_rule" {
    for_each = local.rules

    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      description                  = lookup(security_rule.value, "description", null)
      source_port_range            = lookup(security_rule.value, "sourcePortRange", null)
      source_port_ranges           = lookup(security_rule.value, "sourcePortRanges", null)
      destination_port_range       = lookup(security_rule.value, "destinationPortRange", null)
      destination_port_ranges      = lookup(security_rule.value, "destinationPortRanges", null)
      source_address_prefix        = lookup(security_rule.value, "sourceAddressPrefix", null)
      source_address_prefixes      = lookup(security_rule.value, "sourceAddressPrefixes", null)
      destination_address_prefix   = lookup(security_rule.value, "destinationAddressPrefix", null)
      destination_address_prefixes = lookup(security_rule.value, "destinationAddressPrefixes", null)
    }
  }
}

#----------------------------------------------------------------------------------------
# nsg subnet associations
#----------------------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "nsg_as" {
  for_each = var.bastion

  subnet_id                 = azurerm_subnet.sn[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}