# Configure the AzureRM Provider
# This block specifies that we will be working with Azure resources.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0" # Use a compatible version
    }
  }

  # Configure remote backend for Terraform state
  # This tells Terraform to store its state file in the specified Azure Storage Account.
  backend "azurerm" {
    resource_group_name  = "rg-dev"      # Your resource group name
    storage_account_name = "storacctdev123" # Your storage account name (globally unique)
    container_name       = "tfstate"        # Your blob container name
    key                  = "terraform.tfstate" # The name of the state file within the container
  }
}

provider "azurerm" {
  features {} # Required for AzureRM provider version 2.x and above
  # The provider will use environment variables (ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID)
  # which will be set by Jenkins using the Service Principal credentials.
}

# Resource Group
# This resource block defines an Azure Resource Group to logically group our infrastructure.
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network (VNet)
# A VNet provides network isolation for your Azure resources.
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet
# A subnet divides the VNet into smaller, manageable segments.
resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group (NSG)
# An NSG acts as a virtual firewall for your VM, controlling inbound and outbound traffic.
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# # Public IP Address
# # A public IP allows inbound connectivity to your VM from the internet.
# resource "azurerm_public_ip" "main" {
#   name                = "${var.prefix}-public-ip"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   allocation_method   = "Dynamic" # Or Static for a fixed IP
# }

# Network Interface (NIC)
# The NIC connects your VM to the virtual network.
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    ##public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Linux Virtual Machine
# This defines the actual virtual machine instance.
resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password # For testing, use SSH keys in production
  disable_password_authentication = false              # Set to true if using SSH keys
  network_interface_ids           = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}