# virtual network
data "azurerm_virtual_network" "vnet" {
  name                = var.bastion.vnet.name
  resource_group_name = var.bastion.vnet.rgname
}

# subnet
resource "azurerm_subnet" "sn" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = var.bastion.subnet_address_prefix
}

# public ip
resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.company}-${var.env}-${var.region}"
  resource_group_name = var.bastion.resourcegroup
  location            = var.bastion.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

# bastion host
  name                = "bas-${var.company}-${var.env}-${var.region}"
  resource_group_name = var.bastion.resourcegroup
  location            = var.bastion.location

  sku                    = try(var.bastion.sku, "Basic")
  scale_units            = try(var.bastion.scale_units, 2)
  copy_paste_enabled     = try(var.bastion.enable.copy_paste, false)
  file_copy_enabled      = try(var.bastion.enable.file_copy, false) && var.bastion.sku != "Basic"
  tunneling_enabled      = try(var.bastion.enable.tunneling, false) && var.bastion.sku != "Basic"
  ip_connect_enabled     = try(var.bastion.enable.ip_connect, false) && var.bastion.sku != "Basic"
  shareable_link_enabled = try(var.bastion.enable.shareable_link, false) && var.bastion.sku != "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.sn.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.company}-${var.env}-${var.region}"
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  location            = data.azurerm_virtual_network.vnet.location

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

# nsg subnet association
resource "azurerm_subnet_network_security_group_association" "nsg_as" {
  subnet_id                 = azurerm_subnet.sn.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
