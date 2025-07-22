variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-vm-infrastructure"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-main"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "subnet-main"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg-main"
}

variable "nat_gateway_name" {
  description = "Name of the NAT Gateway"
  type        = string
  default     = "nat-gateway-main"
}

variable "public_ip_nat_name" {
  description = "Name of the public IP for NAT Gateway"
  type        = string
  default     = "pip-nat-gateway"
}

variable "jumpbox_name" {
  description = "Name of the jumpbox VM"
  type        = string
  default     = "vm-jumpbox"
}

variable "jumpbox_public_ip_name" {
  description = "Name of the jumpbox public IP"
  type        = string
  default     = "pip-jumpbox"
}

variable "linux_vm_names" {
  description = "Names of the Linux VMs"
  type        = list(string)
  default     = ["vm-linux-01", "vm-linux-02", "vm-linux-03"]
}

variable "vm_size" {
  description = "Size of the virtual machines"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "development"
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "vm-infrastructure"
}
