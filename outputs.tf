output "bastion_hosts" {
  value = azurerm_bastion_host.bastion
}

output "merged_ids" {
  value = concat(values(azurerm_public_ip.pip)[*].id, values(azurerm_bastion_host.bastion)[*].id, values(azurerm_network_security_group.nsg)[*].id)
}