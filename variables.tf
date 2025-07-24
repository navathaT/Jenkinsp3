variable "resource_group_name" {
  description = "The name of the resource group to create."
  type        = string
  default     = "rg-dev1"
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "eastus"
}

variable "prefix" {
  description = "A prefix for all resource names to ensure uniqueness and organization."
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
  default     = "Standard_B1s" # A small, cost-effective VM size
}

variable "admin_username" {
  description = "The admin username for the Linux VM."
  type        = string
  default     = "Azureuser"
}

variable "admin_password" {
  description = "The admin password for the Linux VM. Use SSH keys in production!"
  type        = string
  sensitive   = true # Mark as sensitive to prevent logging
}
