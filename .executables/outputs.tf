output "vm_public_ip" {
  description = "Public IP of VM"
  value       = azurerm_public_ip.pubip.ip_address
}

output "vm_username" {
  value = var.admin_username
}
