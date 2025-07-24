# output "public_ip_address" {
#   description = "The public IP address of the Linux VM."
#   value       = azurerm_public_ip.main.ip_address
# }

# output "vm_fqdn" {
#   description = "The FQDN of the Linux VM (if a public DNS label is assigned)."
#   value       = azurerm_public_ip.main.fqdn
# }

output "vm_private_ip" {
  description = "The private IP address of the Linux VM."
  value       = azurerm_network_interface.main.ip_configuration[0].private_ip_address
}