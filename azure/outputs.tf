output "nsg_id" {
  description = "The ID of the Network Security Group associated with the bastion."
  value       = azurerm_network_security_group.bastion.id
}

output "vmss_id" {
  description = "The ID of the Linux Virtual Machine Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.bastion.id
}

output "vmss_identity_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity for the VMSS."
  value       = azurerm_linux_virtual_machine_scale_set.bastion.identity[0].principal_id
}
