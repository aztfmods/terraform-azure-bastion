locals {
  rules = [
    {
      name                       = "AllowHttpsInbound"
      description                = "Allow connection from any host on https"
      protocol                   = "Tcp"
      sourcePortRange            = "*"
      destinationPortRange       = 443
      sourceAddressPrefix        = "Internet"
      destinationAddressPrefix   = "*"
      access                     = "Allow"
      priority                   = 100
      direction                  = "Inbound"
      sourcePortRanges           = []
      destinationPortRanges      = []
      sourceAddressPrefixes      = []
      destinationAddressPrefixes = []
    },
    {
      name                       = "AllowGatewayManagerInbound"
      description                = "This enables the control plane, that is, Gateway Manager to be able to talk to Azure Bastion."
      protocol                   = "Tcp"
      sourcePortRange            = "*"
      destinationPortRange       = 443
      sourceAddressPrefix        = "GatewayManager"
      destinationAddressPrefix   = "*"
      access                     = "Allow"
      priority                   = 110
      direction                  = "Inbound"
      sourcePortRanges           = []
      destinationPortRanges      = []
      sourceAddressPrefixes      = []
      destinationAddressPrefixes = []
    },
    {
      name                     = "AllowSshRdpOutbound"
      description              = "Egress Traffic to target VMs: Azure Bastion will reach the target VMs over private IP and SSH/RDP port"
      protocol                 = "*"
      sourcePortRange          = "*"
      sourceAddressPrefix      = "*"
      destinationAddressPrefix = "VirtualNetwork"
      access                   = "Allow"
      priority                 = 100
      direction                = "Outbound"
      sourcePortRanges         = []
      destinationPortRanges = [
        "22",
        "3389"
      ]
      sourceAddressPrefixes      = []
      destinationAddressPrefixes = []
    },
    {
      name                       = "AllowAzureCloudOutbound"
      description                = "Egress Traffic to other public endpoints in Azure"
      protocol                   = "Tcp"
      sourcePortRange            = "*"
      destinationPortRange       = 443
      sourceAddressPrefix        = "*"
      destinationAddressPrefix   = "AzureCloud"
      access                     = "Allow"
      priority                   = 110
      direction                  = "Outbound"
      sourcePortRanges           = []
      destinationPortRanges      = []
      sourceAddressPrefixes      = []
      destinationAddressPrefixes = []
    },
    {
      name                     = "AllowBastionCommunication"
      description              = "Egress Traffic to other public endpoints in Azure"
      protocol                 = "*"
      sourcePortRange          = "*"
      sourceAddressPrefix      = "VirtualNetwork"
      destinationAddressPrefix = "VirtualNetwork"
      access                   = "Allow"
      priority                 = 120
      direction                = "Outbound"
      #sourcePortRanges         = []
      destinationPortRanges = [
        "8080",
        "5701"
      ]
      sourceAddressPrefixes      = []
      destinationAddressPrefixes = []
    },
    {
      name                       = "AllowGetSessionInformation"
      description                = "Egress Traffic to other public endpoints in Azure"
      protocol                   = "*"
      sourcePortRange            = "*"
      sourceAddressPrefix        = "*"
      destinationPortRange       = 80
      destinationAddressPrefix   = "Internet"
      access                     = "Allow"
      priority                   = 130
      direction                  = "Outbound"
      sourcePortRanges           = []
      destinationPortRanges      = []
      sourceAddressPrefixes      = []
      destinationAddressPrefixes = []
    }
  ]
}