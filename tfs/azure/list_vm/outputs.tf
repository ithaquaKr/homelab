output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "virtual_network_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.main.name
}

output "jumpbox_public_ip" {
  description = "Public IP address of the jumpbox"
  value       = azurerm_public_ip.jumpbox.ip_address
}

output "jumpbox_private_ip" {
  description = "Private IP address of the jumpbox"
  value       = azurerm_network_interface.jumpbox.private_ip_address
}

output "linux_vm_private_ips" {
  description = "Private IP addresses of the Linux VMs"
  value       = azurerm_network_interface.linux_vm[*].private_ip_address
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = azurerm_public_ip.nat_gateway.ip_address
}

output "ssh_connection_command" {
  description = "SSH command to connect to jumpbox"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.jumpbox.ip_address}"
}

output "linux_vm_names_and_ips" {
  description = "Names and private IPs of Linux VMs for SSH from jumpbox"
  value = {
    for i, vm_name in var.linux_vm_names :
    vm_name => azurerm_network_interface.linux_vm[i].private_ip_address
  }
}
